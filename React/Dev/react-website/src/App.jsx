import './App.css'
import Nav from './assets/components/nav'
import { Routes, Route } from 'react-router-dom'
import Projects from './pages/projects'
import Tools from './pages/tools'
import Contact from './pages/contact'
import Footer from './assets/components/footer'

function Home() {
  return (
    <>
      <Nav />
      <h2>Welcome to my website!</h2>
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
    </Routes>
  )
}