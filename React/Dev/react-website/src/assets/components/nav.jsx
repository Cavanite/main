import reactLogo from '../../images/react.svg'
import profile_pic from '../../images/profile_picture.png'
import githubLogo from '../../images/github.png'
import { useNavigate } from 'react-router-dom'


const NavItems = [
    { id: 1, title: "Home", path: "/" },
    { id: 2, title: "Tools", path: "/tools" },
    { id: 3, title: "Projects", path: "/projects" },
    { id: 4, title: "Contact", path: "/contact" },
]

function Nav() {
    const navigate = useNavigate()
    return (
        <nav>
            <a href="https://react.dev" target="_blank" rel="noopener noreferrer">
                <img src={reactLogo} className="nav--logo" alt="React logo" />
            </a>
            <img src={profile_pic} className="nav--profile-pic" alt="Profile" />
            {NavItems.map(item => (
                item.external ? (
                    <a className="nav--title" key={item.id} href={item.path} target="_blank" rel="noopener noreferrer">
                        {item.title}
                    </a>
                ) : (
                    <button key={item.id} className="nav--title" onClick={() => navigate(item.path)}>
                        {item.title}
                    </button>
                )
            ))}
            <a href="https://github.com/Cavanite" target="_blank" rel="noopener noreferrer">
                <img src={githubLogo} className="nav--icon" alt="GitHub" />
            </a>
        </nav>
    )
}

export default Nav