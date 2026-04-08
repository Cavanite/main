import { useNavigate } from 'react-router-dom'

function ProjectsBackButton() {
    const navigate = useNavigate()
    return (
        <button className="projects-back-button" onClick={() => navigate('/projects')}>
            ← Back to Projects
        </button>
    )
}
export default ProjectsBackButton