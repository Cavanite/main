import './App.css'
import Nav from './assets/components/nav'
import { Routes, Route } from 'react-router-dom'
import Projects from './pages/projects'
import Tools from './pages/tools'
import Contact from './pages/contact'
import Footer from './assets/components/footer'
import RandomCats from './pages/randomcats'
import KTM from './pages/ktm'
import ScrollToBottom from './assets/components/ScrollToBottom'

function Home() {
  return (
    <>
      <Nav />
      <div className="home-container">
        <h1 className="home-title">Hello, I'm Cavanite!</h1>
        <p className="home-description">Welcome to my personal website where I share my projects, tools, and contact information. Feel free to explore and learn more about me!</p>
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
    </Routes>
  )
}