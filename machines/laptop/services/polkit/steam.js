polkit.addRule( function( action, subject ) {

    if (
        action.id === "org.freedesktop.NetworkManager.settings.modify.system"
    ) {
        var name = polkit.spawn( [
            "cat",
            "/proc/" + subject.pid + "/comm"
        ] );
        if ( name.includes( "steam" ) ) {
            polkit.log( "ignoring steam NM prompt" );
            return polkit.Result.NO;
        }
    }

} );
