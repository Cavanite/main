import Nav from "../assets/components/nav"
import Footer from "../assets/components/footer"
import ScrollToBottom from '../assets/components/ScrollToBottom'

const projects = [
    { id: 1, Title: "React Website", Description: "A personal website built with React to showcase my projects and skills." },
    { id: 2, Title: "React Dashboard", Description: "A simple Desktop Application with some open API's.." },
]

function Projects() {
    return (
        <>
            <Nav />
            <div className="Projects-Grids" style={{ marginTop: '5rem' }}>
                {projects.map((project) => (
                    <div key={project.id} className="Projects-Grid">
                        <h3>{project.Title}</h3>
                        <p>{project.Description}</p>
                    </div>
                ))}
            </div>
            <ScrollToBottom />
            <Footer />
        </>
    )
}
export default Projects
