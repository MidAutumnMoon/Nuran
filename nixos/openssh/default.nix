{ services.openssh = {

    enable = true;

    settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
    };

}; }

