import Nav from "../assets/components/Nav"
import Footer from "../assets/components/Footer"
import ScrollToBottom from '../assets/components/ScrollToBottom'
import PayPalMe from "../assets/components/PayPalMe";

const projects = [
    { id: 1, Title: "React Website", Description: "A personal website built with React to showcase my projects and skills.", Path: "/projects/react-website" },
    { id: 2, Title: "React Dashboard", Description: "A simple Desktop Application with some open API's..", Path: "/dashboard" },
    { id: 3, Title: "Vacation Mode Creator", Description: "A tool to create vacation modes for various applications.", Path: "/projects/vacation-mode-creator" },
]

function Projects() {
    return (
        <>
            <Nav />
            <div className="Projects-Grids" style={{ marginTop: '5rem' }}>
                {projects.map((project) => (
                    <a
                        key={project.id}
                        href={project.Path}
                        className="Projects-Grid"
                        style={{ textDecoration: 'none', color: 'inherit' }}
                    >
                        <h3>{project.Title}</h3>
                        <p>{project.Description}</p>
                    </a>
                ))}
            </div>
            <PayPalMe />
            <Footer />
        </>
    )
}
export default Projects
