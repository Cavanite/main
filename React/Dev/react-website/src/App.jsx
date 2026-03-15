import './App.css'
import Nav from './assets/components/Nav'
import { Routes, Route } from 'react-router-dom'
import Projects from './pages/Projects'
import Tools from './pages/Tools'
import Contact from './pages/Contact'
import Footer from './assets/components/Footer'
import RandomCats from './pages/RandomCats'
import KTM from './pages/KTM'
import ReactWebsite from './pages/projects/ReactWebsite'
import ScrollToBottom from './assets/components/ScrollToBottom'
import Dashboard from './pages/Dashboard'

const CurrentWork = "Bizway B.V.";
const CurrentWorkLink = "https://www.bizway.nl/"

function Home() {
  return (
    <>
      <Nav />
      <div className="home-container">
        <h2 className="home-title">Hello ✋, I'm Bert!</h2>
        <p className="home-description">
          Welcome to my personal website where I share my projects, tools, and contact information.
          Feel free to explore and learn more about me!
          I am passionate about technology and love creating useful tools and projects. If you have any questions or want to collaborate, don't hesitate to reach out through the contact page.
          I'm currently working as a Cloud Engineer at <a href={CurrentWorkLink} target="_blank" rel="noopener noreferrer">{CurrentWork}</a>.
        </p>
        <p>Most of the time I work with PowerShell and Microsoft 365, but I also enjoy learning new technologies and programming languages.</p>
        <p>Feel free to contact me on <a href="https://www.linkedin.com/in/bert-de-zeeuw-6b5291125/" target="_blank" rel="noopener noreferrer">LinkedIn</a>.</p>
      </div>
      <ScrollToBottom />
      <Footer />
    </>
  )
}

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/projects" element={<Projects />} />
      <Route path="/tools" element={<Tools />} />
      <Route path="/contact" element={<Contact />} />
      <Route path="/randomcats" element={<RandomCats />} />
      <Route path="/ktm" element={<KTM />} />
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/projects/react-website" element={<ReactWebsite />} />
    </Routes>
  )
}