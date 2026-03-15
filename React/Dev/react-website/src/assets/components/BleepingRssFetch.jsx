import { useEffect, useState } from 'react'

const SECURITY_UPDATES_URL = import.meta.env.DEV
    ? '/api/security-feed/feed/'
    : 'https://www.bleepingcomputer.com/feed/'
const RECENT_DAYS = 14
const INITIAL_VISIBLE_ITEMS = 8

function stripHtml(value) {
    return value.replaceAll(/<[^>]+>/g, ' ').replaceAll(/\s+/g, ' ').trim()
}

function normalizeUpdates(xmlText) {
    const cutoffDate = new Date()
    const parser = new DOMParser()
    const xmlDocument = parser.parseFromString(xmlText, 'text/xml')
    const parserError = xmlDocument.querySelector('parsererror')

    cutoffDate.setDate(cutoffDate.getDate() - RECENT_DAYS)

    if (parserError) {
        throw new Error('Failed to parse the BleepingComputer RSS feed.')
    }

    return [...xmlDocument.querySelectorAll('item')]
        .map((item) => {
            const title = item.querySelector('title')?.textContent?.trim() || 'Untitled article'
            const link = item.querySelector('link')?.textContent?.trim() || '#'
            const description = item.querySelector('description')?.textContent?.trim() || ''
            const category = item.querySelector('category')?.textContent?.trim() || 'BleepingComputer'
            const pubDate = item.querySelector('pubDate')?.textContent?.trim() || ''

            return {
                title,
                link,
                category,
                description: stripHtml(description),
                pubDate,
            }
        })
        .filter((item) => {
            const releaseDate = new Date(item.pubDate)

            return !Number.isNaN(releaseDate.getTime()) && releaseDate >= cutoffDate
        })
        .sort((left, right) => new Date(right.pubDate) - new Date(left.pubDate))
}

function getErrorMessage(error) {
    if (error instanceof TypeError) {
        return 'The BleepingComputer RSS feed could not be reached from the browser. Local development works through the Vite proxy, but production still needs a server-side proxy because this feed does not expose CORS headers.'
    }

    return error.message || 'Failed to load security feed items.'
}

function formatDate(value) {
    return new Date(value).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
    })
}

function BleepingRssFetch() {
    const [updates, setUpdates] = useState([])
    const [loading, setLoading] = useState(true)
    const [error, setError] = useState(null)
    const [showAll, setShowAll] = useState(false)

    const visibleUpdates = showAll
        ? updates
        : updates.slice(0, INITIAL_VISIBLE_ITEMS)

    useEffect(() => {
        let isMounted = true

        async function loadUpdates() {
            try {
                const response = await fetch(SECURITY_UPDATES_URL)

                if (!response.ok) {
                    throw new Error(`Failed to fetch security feed: ${response.status}`)
                }

                const data = await response.text()

                if (isMounted) {
                    setUpdates(normalizeUpdates(data))
                }
            } catch (err) {
                if (isMounted) {
                    setError(getErrorMessage(err))
                }
            } finally {
                if (isMounted) {
                    setLoading(false)
                }
            }
        }

        loadUpdates()

        return () => {
            isMounted = false
        }
    }, [])

    return (
        <div className="Rss-News-Grids">
            <div className="Rss-News-Grid-Header">
                <h2>BleepingComputer Feed</h2>
                <p>Latest security stories from the last 14 days.</p>
            </div>

            {loading && <p className="Rss-News-State">Loading security feed...</p>}
            {error && <p className="Rss-News-State">Error: {error}</p>}
            {!loading && !error && updates.length === 0 && (
                <p className="Rss-News-State">No BleepingComputer feed items were published in the last 14 days.</p>
            )}

            {!loading && !error && updates.length > 0 && visibleUpdates.map((update) => (
                <a
                    key={update.link}
                    href={update.link}
                    className="Rss-News-Grid-item"
                    target="_blank"
                    rel="noreferrer"
                >
                    <h3 className="Rss-News-Grid-Item-Title">{update.title}</h3>
                    <p className="Rss-News-Grid-Item-Category">{update.category}</p>
                    <p className="Rss-News-Grid-Item-Description">{update.description}</p>
                    <p className="Rss-News-Grid-Item-Date">{formatDate(update.pubDate)}</p>
                </a>
            ))}

            {!loading && !error && updates.length > INITIAL_VISIBLE_ITEMS && (
                <div className="Rss-News-Grid-Controls">
                    <button
                        type="button"
                        className="Rss-News-Toggle-Button"
                        onClick={() => setShowAll((currentValue) => !currentValue)}
                    >
                        {showAll ? 'Show Less' : 'Show More'}
                    </button>
                </div>
            )}
        </div>
    )
}

export default BleepingRssFetch