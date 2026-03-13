import reactLogo from '../../images/react.svg'
import profile_pic from '../../images/profile_picture.png'
import { useNavigate } from 'react-router-dom'

function Nav() {
    const navigate = useNavigate()
    return (
        <nav>
            <a href="https://react.dev" target="_blank" rel="noopener noreferrer">
                <img src={reactLogo} className="nav--logo" alt="React logo" />
            </a>
            <img src={profile_pic} className="nav--profile-pic" alt="Profile" />
            <button className="nav--title" onClick={() => navigate('/')}>Home</button>
            <button className="nav--title" onClick={() => navigate('/tools')}>Tools</button>
            <button className="nav--title" onClick={() => navigate('/projects')}>Projects</button>
            <button className="nav--title" onClick={() => navigate('/contact')}>Contact</button>
        </nav>
    )
}

export default Nav