function handleClick() {
    window.scrollTo({
        top: document.documentElement.scrollHeight,
        behavior: 'smooth'
    });
}

function ScrollToBottom() {
    return (
        <button className="scroll-to-bottom" onClick={handleClick} aria-label="Scroll to bottom">
            ↓
        </button>
    )
}
export default ScrollToBottom