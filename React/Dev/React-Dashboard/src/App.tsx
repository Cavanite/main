import { useState, useEffect } from 'react'
import './App.css'

interface WeatherData {
    current: {
        temperature_2m: number
        wind_speed_10m: number
    }
    hourly: {
        temperature_2m: number[]
        relative_humidity_2m: number[]
        wind_speed_10m: number[]
    }
}

interface RSSItem {
    title: string
    link: string
    pubDate: string
    description: string
    guid?: string
}

interface RSS2JSONResponse {
    status: string
    items: {
        title: string
        link: string
        pubDate: string
        description: string
        guid?: string
    }[]
}

function App() {
    const [weather, setWeather] = useState<WeatherData | null>(null)
    const [loading, setLoading] = useState<boolean>(true)
    const [error, setError] = useState<string | null>(null)

    const [news, setNews] = useState<RSSItem[]>([])
    const [newsLoading, setNewsLoading] = useState<boolean>(true)
    const [newsError, setNewsError] = useState<string | null>(null)

    useEffect(() => {
        const fetchWeather = async () => {
            try {
                const response = await fetch(
                    'https://api.open-meteo.com/v1/forecast?latitude=52.08&longitude=4.75&current=temperature_2m,wind_speed_10m&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m'
                )

                if (!response.ok) {
                    throw new Error('Failed to fetch weather data')
                }

                const data: WeatherData = await response.json()
                setWeather(data)
                setLoading(false)
            } catch (err) {
                setError(err instanceof Error ? err.message : 'An error occurred')
                setLoading(false)
            }
        }

        fetchWeather()

        // Set up hourly refresh (3600000 ms = 1 hour) // changed from 3600000 ms to 60000 ms for minute updates
        const weatherInterval = setInterval(fetchWeather, 60000)

        // Cleanup interval on component unmount
        return () => clearInterval(weatherInterval)
    }, [])

    useEffect(() => {
        const fetchNews = async () => {
            try {
                const feedUrl = 'https://www.bleepingcomputer.com/feed/'
                const response = await fetch(
                    `https://api.rss2json.com/v1/api.json?rss_url=${encodeURIComponent(feedUrl)}&count=10`
                )

                if (!response.ok) {
                    throw new Error('Failed to fetch news')
                }

                const data: RSS2JSONResponse = await response.json()

                if (data.status !== 'ok') {
                    throw new Error('RSS feed error')
                }

                const items: RSSItem[] = data.items.map((item) => ({
                    title: item.title,
                    link: item.link,
                    pubDate: item.pubDate,
                    description: item.description,
                    guid: item.guid || item.link
                }))

                setNews(items.slice(0, 4))
                setNewsLoading(false)
            } catch (err) {
                console.error('News fetch error:', err)
                setNewsError(err instanceof Error ? err.message : 'Failed to load news')
                setNewsLoading(false)
            }
        }

        fetchNews()

        // Set up hourly refresh (3600000 ms = 1 hour)
        const newsInterval = setInterval(fetchNews, 3600000)

        // Cleanup interval on component unmount
        return () => clearInterval(newsInterval)
    }, [])

    return (
        <>
            <h1 className='Dashboard'>Dashboard</h1>

            <div className='Weather-card'>
                {loading && <p>Loading weather data...</p>}
                {error && <p>Error: {error}</p>}
                {weather && (
                    <div>
                        <h2>Current Weather (Bodegraven, NL)</h2>
                        <p>Temperature: {weather.current.temperature_2m}°C</p>
                        <p>Wind Speed: {weather.current.wind_speed_10m} km/h</p>
                        <h3>Hourly Forecast</h3>
                        <p>First hour temp: {weather.hourly.temperature_2m[0]}°C</p>
                        <p>First hour humidity: {weather.hourly.relative_humidity_2m[0]}%</p>
                    </div>
                )}
            </div>

            <div className='News-section'>
                <h2>Latest Tech News - BleepingComputer</h2>
                {newsLoading && <p>Loading news...</p>}
                {newsError && <p>Error: {newsError}</p>}
                {!newsLoading && !newsError && news.length > 0 && (
                    <div className='news-grid'>
                        {news.map((item, index) => (
                            <div key={item.guid || index} className='news-item'>
                                <h3>
                                    <a href={item.link} target="_blank" rel="noopener noreferrer">
                                        {item.title}
                                    </a>
                                </h3>
                                <p className='news-date'>
                                    {new Date(item.pubDate).toLocaleString('nl-NL', {
                                        day: 'numeric',
                                        month: 'short',
                                        hour: '2-digit',
                                        minute: '2-digit'
                                    })}
                                </p>
                                <p className='news-description' dangerouslySetInnerHTML={{
                                    __html: item.description.replace(/<[^>]*>/g, '').substring(0, 120) + '...'
                                }} />
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </>
    )
}

export default App