import Nav from "../assets/components/nav"
import ProfilePic from '../images/profile_picture.png'
import { useState } from "react"
import Footer from "../assets/components/footer"

function Contact() {
    const [form, setForm] = useState({ name: '', email: '', message: '' })
    const [submitted, setSubmitted] = useState(false)

    function handleChange(e) {
        setForm({ ...form, [e.target.name]: e.target.value })
    }

    function handleSubmit(e) {
        e.preventDefault()
        setSubmitted(true)
    }

    return (
        <>
            <Nav />
            <div className="contact-container">
                <img src={ProfilePic} alt="Profile" className="contact-profile-pic" />
                <h2 className="contact--title">Contact Me</h2>

                {submitted ? (
                    <p className="contact-success">Thanks! I'll get back to you soon.</p>
                ) : (
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
                        <button className="contact-submit" type="submit">Send</button>
                    </form>
                )}
            </div>
            <Footer />
        </>
    )
}

export default Contact