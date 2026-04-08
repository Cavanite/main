import { useState, useEffect, useCallback, useRef } from 'react';
import { Providers } from '@microsoft/mgt-element';
import { useNavigate } from 'react-router-dom';
import Nav from '../../assets/components/Nav';
import Footer from '../../assets/components/Footer';
import ProjectsBackButton from '../../assets/components/ProjectsBackButton';
import PayPalMe from '../../assets/components/PayPalMe';

const EXCLUDE_PATTERNS = [
    'admin', 'administrator', 'breakglass', 'break-glass', 'break.glass',
    'emergency', 'emerg', 'privileged', 'service', 'svc', 'system'
];

function shouldExclude(displayName, upn) {
    const lower = (s) => s.toLowerCase();
    return (
        EXCLUDE_PATTERNS.some(p => lower(displayName).includes(p) || lower(upn).includes(p)) ||
        upn.includes('#EXT#')
    );
}

async function callGraph(method, endpoint, body = null) {
    const token = await Providers.globalProvider.getAccessToken();
    const options = {
        method,
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    };
    if (body) options.body = JSON.stringify(body);
    const url = endpoint.startsWith('http') ? endpoint : `https://graph.microsoft.com/v1.0${endpoint}`;
    const res = await fetch(url, options);
    if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err?.error?.message || `HTTP ${res.status}`);
    }
    if (res.status === 204) return null;
    return res.json();
}

function normalizeCountryToken(value) {
    return value
        .toLowerCase()
        .normalize('NFD')
        .replaceAll(/[\u0300-\u036f]/g, '')
        .replaceAll(/[.']/g, '')
        .replaceAll('&', ' and ')
        .replaceAll(/[^a-z0-9]+/g, ' ')
        .trim();
}

function buildCountryNameLookup() {
    const regionName = new Intl.DisplayNames(['en'], { type: 'region' });
    const lookup = new Map();

    for (let first = 65; first <= 90; first += 1) {
        for (let second = 65; second <= 90; second += 1) {
            const code = String.fromCodePoint(first, second);
            const name = regionName.of(code);
            if (name && name !== code) {
                lookup.set(normalizeCountryToken(name), code);
            }
        }
    }

    const aliases = {
        usa: 'US',
        'united states of america': 'US',
        uk: 'GB',
        'united kingdom': 'GB',
        holland: 'NL',
        czechia: 'CZ',
        'ivory coast': 'CI',
        'south korea': 'KR',
        'north korea': 'KP',
        'dr congo': 'CD',
        'congo drc': 'CD',
    };

    Object.entries(aliases).forEach(([name, code]) => {
        lookup.set(normalizeCountryToken(name), code);
    });

    return lookup;
}

const COUNTRY_NAME_LOOKUP = buildCountryNameLookup();
const COUNTRY_DISPLAY_NAMES = new Intl.DisplayNames(['en'], { type: 'region' });

function buildCountryOptions() {
    const regionName = new Intl.DisplayNames(['en'], { type: 'region' });
    const codes = [...new Set(COUNTRY_NAME_LOOKUP.values())];
    return codes
        .map((code) => ({ code, name: regionName.of(code) || code }))
        .sort((left, right) => left.name.localeCompare(right.name));
}

const COUNTRY_OPTIONS = buildCountryOptions();

export default function VacationModeDashboard() {
    const navigate = useNavigate();
    //
    // Auth guard is temporarily disabled for preview/testing.
    // useEffect(() => {
    //     const checkAuth = () => {
    //         if (!Providers.globalProvider || Providers.globalProvider.state !== ProviderState.SignedIn) {
    //             navigate('/projects/vacation-mode-creator');
    //         }
    //     };
    //     checkAuth();
    //     Providers.onProviderUpdated(checkAuth);
    //     return () => Providers.removeProviderUpdatedListener(checkAuth);
    // }, [navigate]);

    // Data
    const [users, setUsers] = useState([]);
    const [namedLocations, setNamedLocations] = useState([]);
    const [caPolicies, setCaPolicies] = useState([]);
    const [vacationPolicies, setVacationPolicies] = useState([]);

    // Selections
    const [selectedUserIds, setSelectedUserIds] = useState(new Set());
    const [userSearch, setUserSearch] = useState('');
    const [selectedVacationLocIds, setSelectedVacationLocIds] = useState(new Set());
    const [selectedHomeLocId, setSelectedHomeLocId] = useState('');
    const [selectedExistingPolicyId, setSelectedExistingPolicyId] = useState('');
    const [selectedRevertTargetPolicyId, setSelectedRevertTargetPolicyId] = useState('');
    const [selectedRevertPolicyIds, setSelectedRevertPolicyIds] = useState(new Set());
    const [namedLocationDisplayName, setNamedLocationDisplayName] = useState('');
    const [namedLocationCountryCodes, setNamedLocationCountryCodes] = useState('');
    const [includeUnknownCountries, setIncludeUnknownCountries] = useState(false);
    const [countrySearchText, setCountrySearchText] = useState('');
    const [createVacationNamedLocationEnabled, setCreateVacationNamedLocationEnabled] = useState(false);

    // Policy fields
    const [ticketNumber, setTicketNumber] = useState('');
    const [ticketOptional, setTicketOptional] = useState(false);
    const [startDate, setStartDate] = useState('');
    const [startDateOptional, setStartDateOptional] = useState(false);
    const [endDate, setEndDate] = useState('');
    const [endDateOptional, setEndDateOptional] = useState(false);

    // UI
    const [statusMessages, setStatusMessages] = useState(['Application started. Sign in was successful.']);
    const [loading, setLoading] = useState(false);
    const statusRef = useRef(null);
    const initialLoadStartedRef = useRef(false);

    useEffect(() => {
        if (statusRef.current) statusRef.current.scrollTop = statusRef.current.scrollHeight;
    }, [statusMessages]);

    const addStatus = useCallback((msg) => {
        const ts = new Date().toLocaleTimeString('en-GB');
        setStatusMessages(prev => [...prev, `[${ts}] ${msg}`]);
    }, []);

    // Auto-generated policy name
    const policyName = (() => {
        const ticket = ticketOptional ? 'NOTICKET' : (ticketNumber.trim() || 'TICKETNUMBER');
        const start = startDateOptional ? 'NOSTARTDATE' : (startDate.trim() || 'STARTDATE');
        const end = endDateOptional ? 'NOENDDATE' : (endDate.trim() || 'ENDDATE');
        const selectedLocs = namedLocations.filter(l => selectedVacationLocIds.has(l.id));
        const country =
            selectedLocs.length === 0 ? 'COUNTRY' :
                selectedLocs.length === 1 ? selectedLocs[0].name :
                    `MULTICOUNTRY-${selectedLocs.length}`;
        const selectedUsrs = users.filter(u => selectedUserIds.has(u.id));
        if (selectedUsrs.length === 0) return `GEO-USERNAME-${country}-${ticket}-${start}-${end}-VACATIONMODE`;
        const usernameSource = selectedUsrs[0].upn || selectedUsrs[0].displayName || 'USERNAME';
        const username = usernameSource.split('@')[0];
        if (selectedUsrs.length === 1) return `GEO-${username}-${country}-${ticket}-${start}-${end}-VACATIONMODE`;
        return `GEO-${username}-Plus${selectedUsrs.length - 1}-${country}-${ticket}-${start}-${end}-VACATIONMODE`;
    })();

    // Fetch users (with pagination)
    const loadUsers = useCallback(async () => {
        setLoading(true);
        addStatus('Fetching users from Entra ID...');
        try {
            let endpoint = '/users?$select=id,displayName,userPrincipalName&$top=999';
            const allUsers = [];
            while (endpoint) {
                const data = await callGraph('GET', endpoint);
                allUsers.push(...data.value);
                endpoint = data['@odata.nextLink'] || null;
            }
            const filtered = allUsers
                .filter(u => !shouldExclude(u.displayName, u.userPrincipalName))
                .map(u => ({
                    ...u,
                    upn: u.userPrincipalName || u.upn || ''
                }))
                .sort((a, b) => a.displayName.localeCompare(b.displayName));
            setUsers(filtered);
            addStatus(`SUCCESS: Loaded ${filtered.length} users (${allUsers.length - filtered.length} filtered out)`);
        } catch (e) {
            addStatus(`ERROR: Failed to fetch users - ${e.message}`);
        }
        setLoading(false);
    }, [addStatus]);

    // Fetch named locations
    const loadNamedLocations = useCallback(async () => {
        addStatus('Loading named locations...');
        try {
            const data = await callGraph('GET', '/identity/conditionalAccess/namedLocations');
            const locs = (data.value || [])
                .sort((a, b) => a.displayName.localeCompare(b.displayName))
                .map(l => ({ name: l.displayName, id: l.id }));
            setNamedLocations(locs);
            addStatus(`SUCCESS: Loaded ${locs.length} named locations`);
        } catch (e) {
            addStatus(`WARNING: Failed to load named locations - ${e.message}`);
        }
    }, [addStatus]);

    // Fetch CA policies (geofencing only)
    const loadCaPolicies = useCallback(async () => {
        addStatus('Loading Conditional Access policies...');
        try {
            const data = await callGraph('GET', '/identity/conditionalAccess/policies');
            const allPolicies = data.value || [];
            const geofencing = allPolicies
                .filter(p => /geofenc|countrywhitelist/i.test(p.displayName))
                .sort((a, b) => a.displayName.localeCompare(b.displayName))
                .map(p => ({ name: p.displayName, id: p.id }));
            const vacation = allPolicies
                .filter(p => /vacationmode/i.test(p.displayName))
                .sort((a, b) => a.displayName.localeCompare(b.displayName))
                .map(p => ({ name: p.displayName, id: p.id }));
            setCaPolicies(geofencing);
            setVacationPolicies(vacation);
            if (geofencing.length === 0) addStatus('WARNING: No geofencing policies found (looking for policies containing "Geofenc" or "Countrywhitelist")');
            else addStatus(`SUCCESS: Loaded ${geofencing.length} geofencing policies`);
            addStatus(`SUCCESS: Loaded ${vacation.length} vacation mode policies`);
        } catch (e) {
            addStatus(`ERROR: Failed to load CA policies - ${e.message}`);
        }
    }, [addStatus]);

    useEffect(() => {
        if (initialLoadStartedRef.current) return;
        initialLoadStartedRef.current = true;
        loadUsers();
        loadNamedLocations();
        loadCaPolicies();
    }, [loadUsers, loadNamedLocations, loadCaPolicies]);

    const toggleUser = (id) => {
        setSelectedUserIds(prev => {
            const next = new Set(prev);
            next.has(id) ? next.delete(id) : next.add(id);
            return next;
        });
    };

    const toggleVacationLoc = (id) => {
        setSelectedVacationLocIds(prev => {
            const next = new Set(prev);
            next.has(id) ? next.delete(id) : next.add(id);
            return next;
        });
    };

    const toggleRevertPolicy = (id) => {
        setSelectedRevertPolicyIds(prev => {
            const next = new Set(prev);
            next.has(id) ? next.delete(id) : next.add(id);
            return next;
        });
    };

    const addCountryToInput = (countryCode) => {
        setNamedLocationCountryCodes((prev) => {
            const existing = prev
                .split(/[\n,;]+/)
                .map((token) => token.trim())
                .filter(Boolean)
                .map((token) => (/^[A-Za-z]{2}$/.test(token) ? token.toUpperCase() : token));
            if (existing.includes(countryCode)) {
                return existing.join(', ');
            }
            return [...existing, countryCode].join(', ');
        });
    };

    const createNamedLocation = async () => {
        if (!createVacationNamedLocationEnabled) {
            alert('Turn on "Create Vacation Named Location" first.');
            return;
        }

        const displayName = namedLocationDisplayName.trim();
        const countryTokens = namedLocationCountryCodes
            .split(/[\n,;]+/)
            .map(token => token.trim())
            .filter(Boolean);

        const invalidCountries = [];
        const countryCodes = countryTokens.map((token) => {
            if (/^[A-Za-z]{2}$/.test(token)) {
                return token.toUpperCase();
            }

            const resolved = COUNTRY_NAME_LOOKUP.get(normalizeCountryToken(token));
            if (!resolved) {
                invalidCountries.push(token);
                return null;
            }
            return resolved;
        }).filter(Boolean);

        if (!displayName) {
            alert('Please enter a display name for the named location.');
            return;
        }
        if (countryCodes.length === 0) {
            alert('Please provide at least one country name or country code (for example: Netherlands, Belgium, DE).');
            return;
        }
        if (invalidCountries.length > 0) {
            alert(`Could not recognize these countries: ${invalidCountries.join(', ')}. Use full country names (English) or 2-letter ISO codes.`);
            return;
        }

        const uniqueCountryCodes = [...new Set(countryCodes)];
        addStatus(`Creating named location${uniqueCountryCodes.length > 1 ? 's' : ''} for ${uniqueCountryCodes.length} countr${uniqueCountryCodes.length > 1 ? 'ies' : 'y'}...`);
        setLoading(true);
        try {
            const createdLocations = [];

            for (const code of uniqueCountryCodes) {
                const countryName = COUNTRY_DISPLAY_NAMES.of(code) || code;
                const locationName = countryName;

                const requestBody = {
                    '@odata.type': '#microsoft.graph.countryNamedLocation',
                    displayName: locationName,
                    countriesAndRegions: [code],
                    includeUnknownCountriesAndRegions: includeUnknownCountries,
                };

                const created = await callGraph('POST', '/identity/conditionalAccess/namedLocations', requestBody);
                createdLocations.push(created);
                addStatus(`SUCCESS: Named location created - ${created.displayName}`);
                addStatus(`  ID: ${created.id}`);
            }

            setNamedLocationDisplayName('');
            setNamedLocationCountryCodes('');
            setIncludeUnknownCountries(false);
            await loadNamedLocations();
            alert(`Created ${createdLocations.length} named location${createdLocations.length > 1 ? 's' : ''}.`);
        } catch (e) {
            addStatus(`ERROR: Failed to create named location - ${e.message}`);
            alert(`Failed to create named location:\n\n${e.message}`);
        }
        setLoading(false);
    };

    const createPolicy = async () => {
        const selectedUsrs = users.filter(u => selectedUserIds.has(u.id));
        const selectedLocs = namedLocations.filter(l => selectedVacationLocIds.has(l.id));
        const homeLocation = namedLocations.find(l => l.id === selectedHomeLocId);

        if (selectedUsrs.length === 0) { alert('Please select at least one user.'); return; }
        if (selectedLocs.length === 0) { alert('Please select at least one vacation destination.'); return; }
        if (!homeLocation) { alert("Please select the user's current location."); return; }
        if (!ticketOptional && !ticketNumber.trim()) { alert('Please enter a ticket number.'); return; }

        const dateRegex = /^\d{2}-\d{2}-\d{4}$/;
        if (!startDateOptional && !startDate.trim()) { alert('Please enter a start date (dd-mm-yyyy).'); return; }
        if (startDate.trim() && !dateRegex.test(startDate)) { alert('Invalid start date. Use dd-mm-yyyy.'); return; }
        if (!endDateOptional && !endDate.trim()) { alert('Please enter an end date (dd-mm-yyyy).'); return; }
        if (endDate.trim() && !dateRegex.test(endDate)) { alert('Invalid end date. Use dd-mm-yyyy.'); return; }

        const userList = selectedUsrs.map(u => `  - ${u.displayName} (${u.upn})`).join('\n');
        const locList = selectedLocs.map(l => `  - ${l.name}`).join('\n');
        const confirmed = globalThis.confirm(
            `Create Conditional Access Policy?\n\n` +
            `Policy: ${policyName}\n\n` +
            `Users (${selectedUsrs.length}):\n${userList}\n\n` +
            `Vacation Destinations (${selectedLocs.length}):\n${locList}\n\n` +
            `Home Location: ${homeLocation.name}\n\n` +
            `This will BLOCK access from ALL locations EXCEPT vacation destinations and home location.\n` +
            `Policy will be created in ENABLED state.\n\nProceed?`
        );
        if (!confirmed) { addStatus('Policy creation cancelled.'); return; }

        addStatus('Creating Conditional Access policy...');
        try {
            const excludeLocationIds = [...new Set([...selectedLocs.map(l => l.id), homeLocation.id])];
            const policyBody = {
                displayName: policyName,
                state: 'enabled',
                conditions: {
                    applications: { includeApplications: ['All'] },
                    users: {
                        includeUsers: selectedUsrs.map(u => u.id),
                        excludeUsers: [],
                        includeGroups: [],
                        excludeGroups: [],
                    },
                    locations: {
                        includeLocations: ['All'],
                        excludeLocations: excludeLocationIds,
                    },
                },
                grantControls: {
                    operator: 'OR',
                    builtInControls: ['block'],
                },
            };

            const newPolicy = await callGraph('POST', '/identity/conditionalAccess/policies', policyBody);
            addStatus(`SUCCESS: Policy created`);
            addStatus(`  Name: ${newPolicy.displayName}`);
            addStatus(`  ID: ${newPolicy.id}`);
            addStatus(`  State: ${newPolicy.state}`);

            // Update existing geofencing policy to exclude vacation users
            if (selectedExistingPolicyId) {
                const existingPolicy = caPolicies.find(p => p.id === selectedExistingPolicyId);
                addStatus(`Updating '${existingPolicy?.name}' to exclude vacation users...`);
                try {
                    const current = await callGraph('GET', `/identity/conditionalAccess/policies/${selectedExistingPolicyId}`);
                    const currentExcluded = current.conditions?.users?.excludeUsers || [];
                    const updatedExcluded = [...new Set([...currentExcluded, ...selectedUsrs.map(u => u.id)])];
                    await callGraph('PATCH', `/identity/conditionalAccess/policies/${selectedExistingPolicyId}`, {
                        conditions: {
                            ...current.conditions,
                            users: { ...current.conditions.users, excludeUsers: updatedExcluded },
                        },
                        grantControls: current.grantControls,
                        sessionControls: current.sessionControls,
                        state: current.state,
                    });
                    addStatus(`SUCCESS: Updated '${existingPolicy?.name}'`);
                } catch (e) {
                    addStatus(`ERROR: Failed to update existing policy - ${e.message}`);
                }
            }

            alert(`Policy created successfully!\n\nName: ${newPolicy.displayName}\nID: ${newPolicy.id}`);
        } catch (e) {
            addStatus(`ERROR: Policy creation failed - ${e.message}`);
            alert(`Failed to create policy:\n\n${e.message}`);
        }
    };

    const signOut = async () => {
        try {
            if (Providers.globalProvider) {
                await Providers.globalProvider.logout();
            }
        } catch (e) {
            addStatus(`WARNING: Sign out redirect failed - ${e.message}`);
        } finally {
            navigate('/projects/vacation-mode-creator', { replace: true });
        }
    };

    const revertVacationMode = async () => {
        const policyIds = [...selectedRevertPolicyIds];
        if (policyIds.length === 0) {
            alert('Please select at least one vacation mode policy to revert.');
            return;
        }
        if (!selectedRevertTargetPolicyId) {
            alert('Please select the geofencing policy where users must be included again.');
            return;
        }

        const selectedNames = vacationPolicies
            .filter(p => selectedRevertPolicyIds.has(p.id))
            .map(p => p.name);
        const revertTargetPolicyName = caPolicies.find(p => p.id === selectedRevertTargetPolicyId)?.name || 'selected geofencing policy';

        const confirmMessage =
            `Are you sure you want to revert these vacation mode policies?\n\n` +
            `Policies to Delete (${policyIds.length}):\n- ${selectedNames.join('\n- ')}\n\n` +
            `Restore users in: ${revertTargetPolicyName}\n\n` +
            `This will:\n` +
            `1. DELETE the selected vacation mode policies\n` +
            `2. REMOVE affected users from the selected geofencing policy exclusion list\n\n` +
            `This action cannot be undone.\n\nProceed?`;

        if (!globalThis.confirm(confirmMessage)) {
            addStatus('Revert cancelled.');
            return;
        }

        addStatus(`Reverting ${policyIds.length} vacation mode policies...`);
        setLoading(true);
        try {
            // Collect users from selected vacation policies before deletion.
            const allUsersToRestore = new Set();
            for (const id of policyIds) {
                const policy = await callGraph('GET', `/identity/conditionalAccess/policies/${id}`);
                const includeUsers = policy?.conditions?.users?.includeUsers || [];
                includeUsers.forEach(userId => allUsersToRestore.add(userId));
            }

            for (const id of policyIds) {
                await callGraph('DELETE', `/identity/conditionalAccess/policies/${id}`);
            }
            addStatus(`SUCCESS: Deleted ${policyIds.length} vacation mode polic${policyIds.length > 1 ? 'ies' : 'y'}`);

            if (allUsersToRestore.size > 0) {
                try {
                    const mainPolicy = await callGraph('GET', `/identity/conditionalAccess/policies/${selectedRevertTargetPolicyId}`);
                    const currentExcluded = mainPolicy?.conditions?.users?.excludeUsers || [];
                    const usersToRemove = [...allUsersToRestore];
                    const updatedExcluded = currentExcluded.filter(id => !usersToRemove.includes(id));

                    await callGraph('PATCH', `/identity/conditionalAccess/policies/${selectedRevertTargetPolicyId}`, {
                        conditions: {
                            ...mainPolicy.conditions,
                            users: {
                                ...mainPolicy.conditions.users,
                                excludeUsers: updatedExcluded,
                            },
                        },
                        grantControls: mainPolicy.grantControls,
                        sessionControls: mainPolicy.sessionControls,
                        state: mainPolicy.state,
                    });
                    const mainPolicyName = caPolicies.find(p => p.id === selectedRevertTargetPolicyId)?.name || 'selected geofencing policy';
                    addStatus(`SUCCESS: Restored ${usersToRemove.length} user(s) in '${mainPolicyName}' exclusion list`);
                } catch (e) {
                    addStatus(`ERROR: Failed to update main geofencing policy - ${e.message}`);
                }
            }

            setSelectedRevertPolicyIds(new Set());
            setSelectedRevertTargetPolicyId('');
            await loadCaPolicies();
            alert('Vacation mode policy revert completed.');
        } catch (e) {
            addStatus(`ERROR: Revert failed - ${e.message}`);
            alert(`Failed to revert vacation mode policies:\n\n${e.message}`);
        }
        setLoading(false);
    };

    const filteredUsers = users.filter(u =>
        !userSearch ||
        u.displayName.toLowerCase().includes(userSearch.toLowerCase()) ||
        u.upn.toLowerCase().includes(userSearch.toLowerCase())
    );

    const filteredCountryOptions = COUNTRY_OPTIONS
        .filter((country) => {
            if (!countrySearchText.trim()) return true;
            const query = countrySearchText.trim().toLowerCase();
            return country.name.toLowerCase().includes(query) || country.code.toLowerCase().includes(query);
        })
        .slice(0, 12);

    return (
        <>
            <Nav />
            <ProjectsBackButton />
            <div className="vmc-container">
                <div className="vmc-header">
                    <h2>Conditional Access Vacation Creator</h2>
                    <div className="vmc-header-actions">
                        <span className="vmc-badge-connected">Connected</span>
                        <button className="vmc-btn vmc-btn-danger" onClick={signOut}>Sign Out</button>
                    </div>
                </div>

                <div className="vmc-main">
                    {/* Left Panel - Users + Status */}
                    <div className="vmc-panel">
                        <div className="vmc-section">
                            <div className="vmc-section-head">
                                <h3>Select Users on Vacation</h3>
                                <button className="vmc-btn vmc-btn-sm" onClick={loadUsers} disabled={loading}>Refresh</button>
                            </div>
                            <input
                                className="vmc-input"
                                placeholder="Search users..."
                                value={userSearch}
                                onChange={e => setUserSearch(e.target.value)}
                            />
                            <div className="vmc-list">
                                {filteredUsers.map(u => (
                                    <label key={u.id} className={`vmc-list-item ${selectedUserIds.has(u.id) ? 'vmc-selected' : ''}`}>
                                        <input type="checkbox" checked={selectedUserIds.has(u.id)} onChange={() => toggleUser(u.id)} />
                                        <span>{u.displayName} <span className="vmc-upn">({u.upn})</span></span>
                                    </label>
                                ))}
                                {filteredUsers.length === 0 && <div className="vmc-empty">{loading ? 'Loading...' : 'No users found'}</div>}
                            </div>
                            <div className="vmc-row">
                                <button className="vmc-btn vmc-btn-sm" onClick={() => setSelectedUserIds(new Set(users.map(u => u.id)))}>Select All</button>
                                <button className="vmc-btn vmc-btn-sm" onClick={() => setSelectedUserIds(new Set())}>Clear</button>
                                <span className="vmc-count">{selectedUserIds.size} selected</span>
                            </div>
                        </div>

                        <div className="vmc-section vmc-status-section">
                            <div className="vmc-section-head">
                                <h3>Status</h3>
                                <button className="vmc-btn vmc-btn-sm" onClick={() => setStatusMessages([])}>Clear</button>
                            </div>
                            <div className="vmc-status-log" ref={statusRef}>
                                {statusMessages.map((msg, i) => <div key={i}>{msg}</div>)}
                            </div>
                        </div>
                    </div>

                    {/* Right Panel - Config */}
                    <div className="vmc-panel">
                        <div className="vmc-section">
                            <div className="vmc-section-head">
                                <h3>Vacation Destination</h3>
                                <button className="vmc-btn vmc-btn-sm" onClick={loadNamedLocations}>Refresh</button>
                            </div>
                            <p className="vmc-hint">Select the Named Location(s) the user(s) are traveling to:</p>
                            <div className="vmc-list vmc-list-sm">
                                {namedLocations.map(l => (
                                    <label key={l.id} className={`vmc-list-item ${selectedVacationLocIds.has(l.id) ? 'vmc-selected' : ''}`}>
                                        <input type="checkbox" checked={selectedVacationLocIds.has(l.id)} onChange={() => toggleVacationLoc(l.id)} />
                                        {l.name}
                                    </label>
                                ))}
                                {namedLocations.length === 0 && <div className="vmc-empty">No named locations found</div>}
                            </div>
                        </div>

                        <div className="vmc-section">
                            <h3>Create Named Location</h3>
                            <p className="vmc-hint">Create a country-based named location using country names or ISO 2-letter codes.</p>
                            <div className="vmc-switch-row">
                                <span>Create Vacation Named Location</span>
                                <label className="vmc-switch" aria-label="Create Vacation Named Location toggle">
                                    <input
                                        type="checkbox"
                                        checked={createVacationNamedLocationEnabled}
                                        onChange={e => setCreateVacationNamedLocationEnabled(e.target.checked)}
                                    />
                                    <span className="vmc-switch-slider" />
                                </label>
                            </div>
                            {createVacationNamedLocationEnabled ? (
                                <>
                                    <div className="vmc-field">
                                        <label htmlFor="named-location-display-name">Display Name</label>
                                        <input
                                            id="named-location-display-name"
                                            className="vmc-input"
                                            placeholder="Vacation Mode Location"
                                            value={namedLocationDisplayName}
                                            onChange={e => setNamedLocationDisplayName(e.target.value)}
                                        />
                                    </div>
                                    <div className="vmc-field">
                                        <label htmlFor="named-location-country-codes">Countries</label>
                                        <textarea
                                            id="named-location-country-codes"
                                            className="vmc-input vmc-textarea"
                                            placeholder="Netherlands, Belgium, DE"
                                            value={namedLocationCountryCodes}
                                            onChange={e => setNamedLocationCountryCodes(e.target.value)}
                                        />
                                    </div>
                                    <div className="vmc-field">
                                        <label htmlFor="named-location-country-search">Search Country</label>
                                        <input
                                            id="named-location-country-search"
                                            className="vmc-input"
                                            placeholder="Type country name or code (e.g. Netherlands / NL)"
                                            value={countrySearchText}
                                            onChange={e => setCountrySearchText(e.target.value)}
                                        />
                                        <div className="vmc-country-search-results">
                                            {filteredCountryOptions.map((country) => (
                                                <button
                                                    key={country.code}
                                                    type="button"
                                                    className="vmc-country-item"
                                                    onClick={() => addCountryToInput(country.code)}
                                                >
                                                    <span>{country.name}</span>
                                                    <span className="vmc-country-code">{country.code}</span>
                                                </button>
                                            ))}
                                            {filteredCountryOptions.length === 0 && (
                                                <div className="vmc-empty">No countries found</div>
                                            )}
                                        </div>
                                    </div>
                                    <label className="vmc-check-label">
                                        <input
                                            type="checkbox"
                                            checked={includeUnknownCountries}
                                            onChange={e => setIncludeUnknownCountries(e.target.checked)}
                                        />
                                        Include unknown countries and regions
                                    </label>
                                    <button className="vmc-btn vmc-btn-sm" onClick={createNamedLocation} disabled={loading}>
                                        Create Named Location
                                    </button>
                                </>
                            ) : (
                                <p className="vmc-hint">Creation is off. Turn on the switch to expand this section.</p>
                            )}
                        </div>

                        <div className="vmc-section">
                            <div className="vmc-section-head">
                                <h3>User's Current Location</h3>
                                <button className="vmc-btn vmc-btn-sm" onClick={loadNamedLocations}>Refresh</button>
                            </div>
                            <p className="vmc-hint">Home location (prevents blocking before departure):</p>
                            <select className="vmc-select" value={selectedHomeLocId} onChange={e => setSelectedHomeLocId(e.target.value)}>
                                <option value="">-- Select home location --</option>
                                {namedLocations.map(l => <option key={l.id} value={l.id}>{l.name}</option>)}
                            </select>
                        </div>

                        <div className="vmc-section">
                            <h3>Main Geofencing Policy</h3>
                            <p className="vmc-hint">Select existing geofencing CA policy to exclude vacation users from (optional):</p>
                            <select className="vmc-select" value={selectedExistingPolicyId} onChange={e => setSelectedExistingPolicyId(e.target.value)}>
                                <option value="">-- None --</option>
                                {caPolicies.map(p => <option key={p.id} value={p.id}>{p.name}</option>)}
                            </select>
                        </div>

                        <div className="vmc-section">
                            <div className="vmc-section-head">
                                <h3>Revert Vacation Mode</h3>
                                <button className="vmc-btn vmc-btn-sm" onClick={loadCaPolicies} disabled={loading}>Refresh</button>
                            </div>
                            <p className="vmc-hint">Select vacation mode policy/policies to delete, then choose the geofencing policy where users should be included again.</p>
                            <div className="vmc-list vmc-list-sm">
                                {vacationPolicies.map(p => (
                                    <label key={p.id} className={`vmc-list-item ${selectedRevertPolicyIds.has(p.id) ? 'vmc-selected' : ''}`}>
                                        <input type="checkbox" checked={selectedRevertPolicyIds.has(p.id)} onChange={() => toggleRevertPolicy(p.id)} />
                                        {p.name}
                                    </label>
                                ))}
                                {vacationPolicies.length === 0 && <div className="vmc-empty">No vacation mode policies found</div>}
                            </div>
                            <div className="vmc-field" style={{ marginTop: '0.75rem' }}>
                                <label htmlFor="revert-target-policy">Select Geofencing Policy To Restore Users In</label>
                                <select
                                    id="revert-target-policy"
                                    className="vmc-select"
                                    value={selectedRevertTargetPolicyId}
                                    onChange={e => setSelectedRevertTargetPolicyId(e.target.value)}
                                >
                                    <option value="">-- Select geofencing policy --</option>
                                    {caPolicies.map(p => <option key={p.id} value={p.id}>{p.name}</option>)}
                                </select>
                            </div>
                        </div>

                        <div className="vmc-section">
                            <h3>Policy Details</h3>

                            <div className="vmc-field">
                                <label>Ticket Number</label>
                                {!ticketOptional && (
                                    <input className="vmc-input" value={ticketNumber} onChange={e => setTicketNumber(e.target.value)} placeholder="e.g. INC0012345" />
                                )}
                                <div className="vmc-switch-row vmc-switch-row-compact">
                                    <span>No ticket number (optional)</span>
                                    <label className="vmc-switch" aria-label="No ticket number toggle">
                                        <input type="checkbox" checked={ticketOptional} onChange={e => { setTicketOptional(e.target.checked); setTicketNumber(''); }} />
                                        <span className="vmc-switch-slider" />
                                    </label>
                                </div>
                            </div>

                            <div className="vmc-field">
                                <label>Start Date <span className="vmc-required">*</span></label>
                                {!startDateOptional && (
                                    <input className="vmc-input" value={startDate} onChange={e => setStartDate(e.target.value)} placeholder="dd-mm-yyyy" />
                                )}
                                <div className="vmc-switch-row vmc-switch-row-compact">
                                    <span>No start date (optional)</span>
                                    <label className="vmc-switch" aria-label="No start date toggle">
                                        <input type="checkbox" checked={startDateOptional} onChange={e => { setStartDateOptional(e.target.checked); setStartDate(''); }} />
                                        <span className="vmc-switch-slider" />
                                    </label>
                                </div>
                            </div>

                            <div className="vmc-field">
                                <label>End Date <span className="vmc-required">*</span></label>
                                {!endDateOptional && (
                                    <input className="vmc-input" value={endDate} onChange={e => setEndDate(e.target.value)} placeholder="dd-mm-yyyy" />
                                )}
                                <div className="vmc-switch-row vmc-switch-row-compact">
                                    <span>No end date (optional)</span>
                                    <label className="vmc-switch" aria-label="No end date toggle">
                                        <input type="checkbox" checked={endDateOptional} onChange={e => { setEndDateOptional(e.target.checked); setEndDate(''); }} />
                                        <span className="vmc-switch-slider" />
                                    </label>
                                </div>
                            </div>

                            <div className="vmc-field">
                                <label>Policy Name (auto-generated)</label>
                                <input className="vmc-input vmc-input-readonly" value={policyName} readOnly />
                            </div>
                        </div>
                    </div>
                </div>

                <div className="vmc-footer">
                    <button className="vmc-btn vmc-btn-warning vmc-btn-lg" onClick={revertVacationMode} disabled={loading}>
                        Revert Vacation Mode
                    </button>
                    <button className="vmc-btn vmc-btn-primary vmc-btn-lg" onClick={createPolicy} disabled={loading}>
                        Create CA Policy
                    </button>
                </div>
            </div>
            <PayPalMe />
            <Footer />
        </>
    );
}
