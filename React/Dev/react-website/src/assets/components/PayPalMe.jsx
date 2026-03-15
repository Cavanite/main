import { useState } from "react";

function PayPalMe() {
    const [showSupport, setShowSupport] = useState(true)

    return (
        showSupport ? (
            <div
                style={{
                    position: 'fixed',
                    left: '1rem',
                    bottom: '1rem',
                    zIndex: 120,
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.4rem',
                }}
            >
                <a
                    href="https://paypal.me/cavanite"
                    target="_blank"
                    rel="noopener noreferrer"
                    style={{
                        display: 'inline-flex',
                        alignItems: 'center',
                        gap: '0.5rem',
                        padding: '0.45rem 0.85rem',
                        border: '1px solid #555',
                        borderRadius: '999px',
                        textDecoration: 'none',
                        color: '#fff',
                        background: '#1a1a1a',
                        fontSize: '0.9rem',
                        boxShadow: '0 6px 14px rgba(0, 0, 0, 0.35)',
                    }}
                >
                    <span
                        aria-hidden="true"
                        style={{
                            width: '40px',
                            height: '40px',
                            borderRadius: '50%',
                            display: 'inline-flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            background: '#0070ba',
                            color: '#fff',
                            fontWeight: 'bold',
                            fontSize: '1rem',
                            lineHeight: 1,
                        }}
                    >
                        P
                    </span>
                    <span>Support me</span>
                </a>

                <button
                    type="button"
                    aria-label="Close support button"
                    onClick={() => setShowSupport(false)}
                    style={{
                        width: '22px',
                        height: '22px',
                        borderRadius: '50%',
                        border: '1px solid #555',
                        background: '#111',
                        color: '#fff',
                        cursor: 'pointer',
                        fontSize: '0.8rem',
                        lineHeight: 1,
                        padding: 0,
                    }}
                >
                    x
                </button>
            </div>
        ) : null
    )
}

export default PayPalMe
