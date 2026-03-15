import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Providers, ProviderState } from "@microsoft/mgt-element";
import { Msal2Provider } from "@microsoft/mgt-msal2-provider";
import { Login } from "@microsoft/mgt-react";

// Initialize the provider once at module level
if (!Providers.globalProvider) {
    Providers.globalProvider = new Msal2Provider({
        clientId: "YOUR_CLIENT_ID", // Replace with your Azure AD app client ID
        authority: "https://login.microsoftonline.com/common",
        scopes: ["User.Read.All", "Policy.Read.All", "Policy.ReadWrite.ConditionalAccess"],
    });
}

const MicrosoftGraphSignIn = () => {
    const navigate = useNavigate();

    useEffect(() => {
        const checkSignIn = () => {
            if (Providers.globalProvider?.state === ProviderState.SignedIn) {
                navigate("/projects/vacation-mode-creator/dashboard");
            }
        };
        checkSignIn();
        Providers.onProviderUpdated(checkSignIn);
        return () => Providers.removeProviderUpdatedListener(checkSignIn);
    }, [navigate]);

    return <Login />;
};

export default MicrosoftGraphSignIn;