import Nav from "../assets/components/Nav"
import Footer from "../assets/components/Footer"
import ScrollToBottom from '../assets/components/ScrollToBottom'

const projects = [
    { id: 1, Title: "React Website", Description: "A personal website built with React to showcase my projects and skills.", Path: "/projects/react-website" },
    { id: 2, Title: "React Dashboard", Description: "A simple Desktop Application with some open API's..", Path: "/dashboard" },
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
            <ScrollToBottom />
            <Footer />
        </>
    )
}
export default Projects
