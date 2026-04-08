import Nav from "../../assets/components/Nav";
import Footer from "../../assets/components/Footer";
import ScrollToBottom from '../../assets/components/ScrollToBottom'
import ProjectsBackButton from "../../assets/components/ProjectsBackButton";
import MicrosoftGraphSignIn from "../../assets/components/MicrosoftGraphSignIn";
import PayPalMe from "../../assets/components/PayPalMe";

function VacationModeCreator() {
    return (
        <>
            <Nav />

            <ProjectsBackButton />
            <div>
                <h2>Vacation Mode Creator</h2>
                <MicrosoftGraphSignIn />
            </div>
            <ScrollToBottom />
            <PayPalMe />
            <Footer />
        </>
    )
}

export default VacationModeCreator