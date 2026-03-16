import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Providers, ProviderState } from "@microsoft/mgt-element";
import { Msal2Provider } from "@microsoft/mgt-msal2-provider";
import { Login } from "@microsoft/mgt-react";

const clientId = import.meta.env.VITE_ENTRA_CLIENT_ID;
const tenantId = import.meta.env.VITE_ENTRA_TENANT_ID;
const redirectUri = import.meta.env.VITE_ENTRA_REDIRECT_URI || globalThis.location?.origin;
const postLogoutRedirectUri = import.meta.env.VITE_ENTRA_POST_LOGOUT_REDIRECT_URI
    || `${globalThis.location?.origin || ''}/projects/vacation-mode-creator`;
const authority = import.meta.env.VITE_ENTRA_AUTHORITY || (tenantId
    ? `https://login.microsoftonline.com/${tenantId}`
    : "https://login.microsoftonline.com/organizations");

// Initialize the provider once at module level
if (!Providers.globalProvider && clientId) {
    Providers.globalProvider = new Msal2Provider({
        clientId,
        authority,
        redirectUri,
        postLogoutRedirectUri,
        scopes: ["User.Read.All", "Policy.Read.All", "Policy.ReadWrite.ConditionalAccess"],
    });
}

const MicrosoftGraphSignIn = () => {
    const navigate = useNavigate();

    useEffect(() => {
        const checkSignIn = () => {
            if (Providers.globalProvider?.state === ProviderState.SignedIn) {
                navigate("/projects/vacation-mode-creator/dashboard");
            }
        };
        checkSignIn();
        Providers.onProviderUpdated(checkSignIn);
        return () => Providers.removeProviderUpdatedListener(checkSignIn);
    }, [navigate]);

    if (!clientId) {
        return (
            <div style={{ color: "#b00020", padding: "0.75rem 0" }}>
                Missing VITE_ENTRA_CLIENT_ID in your environment configuration.
            </div>
        );
    }

    return <Login />;
};

export default MicrosoftGraphSignIn;