import Footer from '../assets/components/Footer'
import BleepingRssFetch from '../assets/components/BleepingRssFetch'
import Nav from '../assets/components/Nav'
import ProjectsBackButton from "../assets/components/ProjectsBackButton";

function Dashboard() {
    return (
        <>
            <Nav />
            <ProjectsBackButton />
            <main className="Dashboard-Sections">
                <section className="Dashboard-Section">
                    <BleepingRssFetch />
                </section>
            </main>
            <Footer />
        </>
    )
}

export default Dashboard