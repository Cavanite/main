import Nav from "../assets/components/Nav"
import Footer from "../assets/components/Footer"
import ScrollToBottom from "../assets/components/ScrollToBottom"


function RandomCats() {
    return (
        <>
            <Nav />
            <div className="randomcats-container">
                <h2 className="randomcats--title">Random Cats</h2>
                <p className="randomcats--description">You have found the hidden cats.</p>
                <img className="randomcats--image" src="https://cataas.com/cat" alt="Random Cat" />
            </div>
            <ScrollToBottom />
            <Footer />
        </>
    )
}

export default RandomCats