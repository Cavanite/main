import Nav from "../assets/components/nav"
import ProfilePic from '../images/profile_picture.png'
import { useState } from "react"
import Footer from "../assets/components/footer"
import ScrollToBottom from '../assets/components/ScrollToBottom'

function CreateCaptcha() {
    const a = Math.floor(Math.random() * 9) + 1
    const b = Math.floor(Math.random() * 9) + 1
    return { a, b, answer: a + b }
}

function Contact() {
    const [form, setForm] = useState({ name: '', email: '', message: '' })
    const [submitted, setSubmitted] = useState(false)
    const [error, setError] = useState(false)
    const [loading, setLoading] = useState(false)

    const [captcha, setCaptcha] = useState(CreateCaptcha())
    const [captchaInput, setCaptchaInput] = useState('')
    const [captchaError, setCaptchaError] = useState(false)

    function handleChange(e) {
        setForm({ ...form, [e.target.name]: e.target.value })
    }

    async function handleSubmit(e) {
        e.preventDefault()

        if (Number(captchaInput) !== captcha.answer) {
            setCaptchaError(true)
            setCaptchaInput('')
            setCaptcha(CreateCaptcha())
            return
        }

        setCaptchaError(false)
        setLoading(true)
        setError(false)

        try {
            const response = await fetch('https://formspree.io/f/mreylgry', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(form),
            })
            if (response.ok) {
                setSubmitted(true)
            } else {
                setError(true)
            }
        } catch {
            setError(true)
        } finally {
            setLoading(false)
        }
    }

    let formContent
    if (submitted) {
        formContent = <p className="contact-success">Thanks! I'll get back to you soon.</p>
    } else if (error) {
        formContent = <p className="contact-error">Something went wrong. Please try again.</p>
    } else {
        formContent = (
            <form className="contact-form" onSubmit={handleSubmit}>
                <input
                    className="contact-input"
                    type="text"
                    name="name"
                    placeholder="Your name"
                    value={form.name}
                    onChange={handleChange}
                    required
                />
                <input
                    className="contact-input"
                    type="email"
                    name="email"
                    placeholder="Your email"
                    value={form.email}
                    onChange={handleChange}
                    required
                />
                <textarea
                    className="contact-input contact-textarea"
                    name="message"
                    placeholder="Your message"
                    value={form.message}
                    onChange={handleChange}
                    required
                />
                <button className="contact-submit" type="submit" disabled={loading}>
                    {loading ? 'Sending...' : 'Send'}
                </button>
                <label className="contact-captcha-label">
                    What is {captcha.a} + {captcha.b}?
                </label>
                <input
                    className="contact-input"
                    type="number"
                    name="captcha"
                    placeholder="Your answer"
                    value={captchaInput}
                    onChange={(e) => setCaptchaInput(e.target.value)}
                    required
                />
                {captchaError && (
                    <p className="contact-error">Wrong answer. Please try again.</p>
                )}
            </form>
        )
    }

    return (
        <>
            <Nav />
            <div className="contact-container">
                <img src={ProfilePic} alt="Profile" className="contact-profile-pic" />
                <h2 className="contact--title">Contact Me</h2>
                <div className="contact-email-row">
                    <h3>Email:</h3>
                    <a href="mailto:bertdezeeuw@live.nl">bertdezeeuw@live.nl</a>
                </div>
                {formContent}
            </div>
            <ScrollToBottom />
            <Footer />
        </>
    )
}

export default Contact