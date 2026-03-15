import Nav from "../../assets/components/Nav";
import Footer from "../../assets/components/Footer";
import ScrollToBottom from '../../assets/components/ScrollToBottom'
import ProjectsBackButton from "../../assets/components/ProjectsBackButton";

function ReactWebsite() {
    return (
        <>
            <Nav />
            <div className="project-detail" style={{ marginTop: '5rem', maxWidth: '700px', margin: '5rem auto', padding: '0 2rem' }}>
                <div style={{ marginBottom: '2rem' }}>
                    <ProjectsBackButton />
                    <h2>React Website</h2>
                </div>
                <p>This website is a personal project built with React to showcase my work and skills.</p>
                <p>Making this was really fun and educational, allowing me to improve my React and web development skills.</p>
                <p>Due to my work as a Cloud Engineer, I often work with Microsoft 365 and PowerShell, but I wanted to create something different to expand my skill set and learn new technologies.</p>
                <h4>Tech Stack</h4>
                <ul className="project-tech-stack">
                    <li>React</li>
                    <li>Vite</li>
                    <li>React Router</li>
                    <li>CSS</li>
                </ul>
                <h4>Docs used:</h4>
                <ul className="project-docs">
                    <li><a href="https://www.w3schools.com" target="_blank" rel="noopener noreferrer">
                        W3Schools
                    </a></li>
                </ul>
            </div>
            <ScrollToBottom />
            <Footer />
        </>
    )
}
export default ReactWebsite