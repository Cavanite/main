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

/**
 * Represents a single item returned from the Cat API.
 * @interface CatApiItem
 * @property {string} url - The URL of the cat image or resource
 */
interface CatApiItem {
    url: string
}

interface PokemonApiItem {
    id: number
    name: string
}

function App() {
    const [weather, setWeather] = useState<WeatherData | null>(null)
    const [loading, setLoading] = useState<boolean>(true)
    const [error, setError] = useState<string | null>(null)

    const [news, setNews] = useState<RSSItem[]>([])
    const [newsLoading, setNewsLoading] = useState<boolean>(true)
    const [newsError, setNewsError] = useState<string | null>(null)

    const [catImageUrl, setCatImageUrl] = useState<string | null>(null)
    const [catLoading, setCatLoading] = useState<boolean>(true)
    const [catError, setCatError] = useState<string | null>(null)
    const [catCountdown, setCatCountdown] = useState<number>(60)
    const [isPokemonRevealed, setIsPokemonRevealed] = useState<boolean>(false)
    const [selectedPokemonGuess, setSelectedPokemonGuess] = useState<string | null>(null)
    const [pokemonStatus, setPokemonStatus] = useState<string>('Pick one answer')
    const [pokemonCountdown, setPokemonCountdown] = useState<number>(15)
    const [correctPokemon, setCorrectPokemon] = useState<string>('')
    const [pokemonImageUrl, setPokemonImageUrl] = useState<string>('')
    const [pokemonOptions, setPokemonOptions] = useState<string[]>([])
    const [pokemonLoading, setPokemonLoading] = useState<boolean>(true)
    const [pokemonError, setPokemonError] = useState<string | null>(null)

    const pokemonRoundSeconds = 15
    const maxPokemonId = 898

    const formatPokemonName = (name: string): string => {
        const spacedName = name.split('-').join(' ')
        return spacedName.charAt(0).toUpperCase() + spacedName.slice(1)
    }

    const getPokemonOptionClassName = (option: string): string => {
        if (!isPokemonRevealed) {
            return 'pokemon-option-btn'
        }

        if (option === correctPokemon) {
            return 'pokemon-option-btn correct'
        }

        if (selectedPokemonGuess === option) {
            return 'pokemon-option-btn wrong'
        }

        return 'pokemon-option-btn'
    }

    const shuffleOptions = (options: string[]): string[] => {
        const shuffled = [...options]
        for (let i = shuffled.length - 1; i > 0; i -= 1) {
            const j = Math.floor(Math.random() * (i + 1))
            const temp = shuffled[i]
            shuffled[i] = shuffled[j]
            shuffled[j] = temp
        }

        return shuffled
    }

    const getRandomPokemonId = (usedIds: Set<number>): number => {
        let id = Math.floor(Math.random() * maxPokemonId) + 1
        while (usedIds.has(id)) {
            id = Math.floor(Math.random() * maxPokemonId) + 1
        }
        usedIds.add(id)
        return id
    }

    const fetchPokemonById = async (id: number): Promise<PokemonApiItem> => {
        const response = await fetch(`https://pokeapi.co/api/v2/pokemon/${id}`)
        if (!response.ok) {
            throw new Error('Failed to fetch pokemon data')
        }

        const data: PokemonApiItem = await response.json()
        return data
    }

    const startNewPokemonRound = async () => {
        try {
            setPokemonLoading(true)
            setPokemonError(null)
            setIsPokemonRevealed(false)
            setSelectedPokemonGuess(null)
            setPokemonStatus('Pick one answer')
            setPokemonCountdown(pokemonRoundSeconds)

            const usedIds = new Set<number>()
            const correctId = getRandomPokemonId(usedIds)
            const correctData = await fetchPokemonById(correctId)
            const correctDisplayName = formatPokemonName(correctData.name)

            const wrongOptions: string[] = []
            while (wrongOptions.length < 3) {
                const wrongId = getRandomPokemonId(usedIds)
                const wrongData = await fetchPokemonById(wrongId)
                const wrongDisplayName = formatPokemonName(wrongData.name)

                if (wrongDisplayName !== correctDisplayName && !wrongOptions.includes(wrongDisplayName)) {
                    wrongOptions.push(wrongDisplayName)
                }
            }

            const options = shuffleOptions([correctDisplayName, ...wrongOptions])

            setCorrectPokemon(correctDisplayName)
            setPokemonOptions(options)
            setPokemonImageUrl(`https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${correctData.id}.png?t=${Date.now()}`)
            setPokemonLoading(false)
        } catch (err) {
            setPokemonError(err instanceof Error ? err.message : 'Failed to load pokemon round')
            setPokemonLoading(false)
        }
    }

    const handlePokemonGuess = (guess: string) => {
        if (isPokemonRevealed || pokemonLoading || !correctPokemon) {
            return
        }

        setSelectedPokemonGuess(guess)
        setIsPokemonRevealed(true)
        if (guess === correctPokemon) {
            setPokemonStatus(`Correct! It is ${correctPokemon}.`)
            return
        }

        setPokemonStatus(`Nope. It was ${correctPokemon}.`)
    }



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

        // Set up 15 second refresh for weather updates
        const weatherInterval = setInterval(fetchWeather, 15000)

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

    useEffect(() => {
        const refreshSeconds = 30

        const fetchCatImage = async () => {
            try {
                setCatLoading(true)
                setCatError(null)

                const response = await fetch('https://api.thecatapi.com/v1/images/search')
                if (!response.ok) {
                    throw new Error('Failed to fetch cat image')
                }

                const data: CatApiItem[] = await response.json()
                if (!data.length || !data[0].url) {
                    throw new Error('No cat image received')
                }

                setCatImageUrl(`${data[0].url}?t=${Date.now()}`)
                setCatCountdown(refreshSeconds)
                setCatLoading(false)
            } catch (err) {
                setCatError(err instanceof Error ? err.message : 'Failed to load cat image')
                setCatLoading(false)
            }
        }

        fetchCatImage()

        const catInterval = setInterval(fetchCatImage, refreshSeconds * 1000)

        const countdownInterval = setInterval(() => {
            setCatCountdown((prev) => (prev <= 1 ? refreshSeconds : prev - 1))
        }, 1000)

        return () => {
            clearInterval(catInterval)
            clearInterval(countdownInterval)
        }
    }, [])

    useEffect(() => {
        startNewPokemonRound()
    }, [])

    useEffect(() => {
        const pokemonCountdownInterval = setInterval(() => {
            setPokemonCountdown((prev) => Math.max(prev - 1, 0))
        }, 1000)

        return () => clearInterval(pokemonCountdownInterval)
    }, [])

    useEffect(() => {
        if (pokemonCountdown === 0) {
            startNewPokemonRound()
        }
    }, [pokemonCountdown])

    let pokemonStatusText = pokemonStatus
    if (pokemonError) {
        pokemonStatusText = `Error: ${pokemonError}`
    } else if (pokemonLoading) {
        pokemonStatusText = 'Loading pokemon...'
    }

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

            <div className='Feeds-panel'>
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
                                        __html: item.description.split(/<[^>]*>/g).join('').substring(0, 120) + '...'
                                    }} />
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            </div>

            <div className='randomcatpanel-section'>
                <div className='randomcat-header'>
                    <h2>Random Cat</h2>
                    <span className='cat-countdown'>{catCountdown}s</span>
                </div>
                {catLoading && <p>Loading cat...</p>}
                {catError && <p>Error: {catError}</p>}
                {!catLoading && !catError && catImageUrl && (
                    <img src={catImageUrl} alt='Random cat' className='randomcat-image' />
                )}
            </div>

            <div className='whoisthispokemon-section'>
                <div className='pokemon-header'>
                    <h2>Who's That Pokemon?</h2>
                    <span className='pokemon-countdown'>{pokemonCountdown}s</span>
                </div>

                <div className='pokemon-image-wrap'>
                    <img
                        className={`pokemon-image ${isPokemonRevealed ? 'revealed' : 'silhouette'}`}
                        src={pokemonImageUrl}
                        alt='Pokemon silhouette'
                    />
                </div>
                <div className='pokemon-options'>
                    {pokemonOptions.map((option) => (
                        <button
                            key={option}
                            className={getPokemonOptionClassName(option)}
                            onClick={() => handlePokemonGuess(option)}
                            disabled={pokemonLoading || !!pokemonError || isPokemonRevealed}
                        >
                            {option}
                        </button>
                    ))}
                </div>
                <p className='pokemon-status'>{pokemonStatusText}</p>
            </div>
        </>
    )
}

export default App