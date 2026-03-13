import Nav from '../assets/components/nav'
import Footer from '../assets/components/footer'
import SpaceSniffer from '../assets/tools-icons/SpaceSniffer.png'
import SpaceSnifferZip from '../assets/tools/spacesniffer.zip?url'
import SMTPDiag from '../assets/tools-icons/SMTP_Diag.png'
import SMTPDiagFile from '../assets/tools/SMTP_Diag_Tool.exe?url'
import CMTrace from '../assets/tools-icons/CMTrace.png'
import CMTraceFile from '../assets/tools/CMTrace.exe?url'
import ScrollToBottom from '../assets/components/ScrollToBottom'


const VacationCreatorFile = 'https://github.com/Cavanite/Conditional-Access-Vacation-Creator/archive/refs/heads/main.zip'

const tools = [
    { id: 1, title: "SpaceSniffer", description: "A tool to visualize disk space usage.", image: SpaceSniffer, files: SpaceSnifferZip, filename: "spacesniffer.zip" },
    { id: 2, title: "SMTP_Diag", description: "A tool to diagnose SMTP server issues.", image: SMTPDiag, files: SMTPDiagFile, filename: "SMTP_Diag_Tool.exe" },
    { id: 3, title: "CMTrace", description: "A tool to view log files.", image: CMTrace, files: CMTraceFile, filename: "CMTrace.exe" },
    { id: 4, title: "Conditional Access Vacation Creator", description: "PowerShell Build Vacation mode tool.", image: null, files: VacationCreatorFile, filename: "Conditional_Access_Vacation_Creator.zip" }
]

function Tools() {
    return (
        <>
            <Nav />

            <div className="Projects-Grids" style={{ marginTop: '5rem' }}>
                <h2 className="tools--title">Tools</h2>
                {tools.map((tool) => (
                    <div className="Projects-Grid" key={tool.id}>
                        <h3>{tool.title}</h3>
                        <a href={tool.files} download={tool.filename}>
                            {tool.image ? <img src={tool.image} alt={tool.title} className="Tools-Image" /> : <p>Download Here</p>}
                        </a>
                        <p>{tool.description}</p>
                    </div>
                ))}
            </div>
            <ScrollToBottom />
            <Footer />
        </>
    )
}
export default Tools
