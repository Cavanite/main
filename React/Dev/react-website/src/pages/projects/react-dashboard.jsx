import Nav from "../../assets/components/nav";
import Footer from "../../assets/components/footer";
import ScrollToBottom from '../../assets/components/ScrollToBottom'
import ProjectsBackButton from "../../assets/components/projects-back-button";

function ReactDashboard() {
    return (
        <>
            <Nav />
            <div className="project-detail" style={{ marginTop: '5rem', maxWidth: '700px', margin: '5rem auto', padding: '0 2rem' }}>
                <ProjectsBackButton />
                <h2>React Dashboard</h2>
                <p>More information coming soon...</p>
            </div>
            <ScrollToBottom />
            <Footer />
        </>
    )
}
export default ReactDashboard