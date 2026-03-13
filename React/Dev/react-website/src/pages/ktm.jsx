import Nav from "../assets/components/nav"
import Footer from "../assets/components/footer"
import KTMImage from "../images/ktm790duke.JPEG"
import ScrollToBottom from '../assets/components/ScrollToBottom'

function KTM() {
    return (
        <>
            <Nav />
            <div className="ktm-container">
                <h2 className="ktm--title">KTM 790 Duke 2020</h2>
                <img className="ktm--image" src={KTMImage} alt="KTM 790 Duke" />
            </div>
            <div className="ktm--section">
                <h2>Overview</h2>
                <p>The KTM 790 Duke is a naked sportbike that offers a blend of performance, agility, and style. It features a powerful 799cc parallel-twin engine, advanced electronics, and a lightweight chassis, making it an excellent choice for riders seeking an exhilarating riding experience.</p>
            </div>
            <div className="ktm--section">
                <h2>Specs</h2>
                <ul>
                    <li>Engine: 799cc parallel-twin</li>
                    <li>Power: 105 hp</li>
                    <li>Torque: 86 Nm</li>
                    <li>Weight: 169 kg (dry)</li>
                    <li>Top Speed: 210 km/h</li>
                </ul>
            </div>
            <ScrollToBottom />
            <Footer />
        </>
    )
}

export default KTM