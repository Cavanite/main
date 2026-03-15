import Footer from '../assets/components/Footer'
import BleepingRssFetch from '../assets/components/BleepingRssFetch'
import Nav from '../assets/components/Nav'
import ProjectsBackButton from "../assets/components/ProjectsBackButton";
import ScrollToBottom from '../assets/components/ScrollToBottom'
import PayPalMe from '../assets/components/PayPalMe'

function Dashboard() {
    return (
        <>
            <Nav />
            <ProjectsBackButton />
            <main className="Dashboard-Sections" style={{ margin: '0 auto', padding: '2rem' }}>
                <section className="Dashboard-Section">
                    <BleepingRssFetch />
                </section>
            </main>
            <ScrollToBottom />
            <PayPalMe />
            <Footer />
        </>
    )
}

export default Dashboard