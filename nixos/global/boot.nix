{

  boot.initrd.includeDefaultModules =
    false;

  boot.initrd.availableKernelModules =
    [ "uhci_hcd"
      "ehci_hcd"
      "ehci_pci"
      "ohci_hcd"
      "ohci_pci"
      "xhci_hcd"
      "xhci_pci"
      "usbhid"
      "hid_generic"
    ];

}
