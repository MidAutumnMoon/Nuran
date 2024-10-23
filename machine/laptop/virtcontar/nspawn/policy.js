polkit.addRule( function( action, subject ) {

    const actionAllowed =
        action.id == 'org.freedesktop.machine1.shell'
        || action.id == 'org.freedesktop.machine1.login'
        || action.id == 'org.freedesktop.machine1.manage-machines'
        ;

    const groupAllowed =
        subject.isInGroup( 'wheel' )
        ;

    if ( actionAllowed && groupAllowed ) {
        return polkit.Result.YES;
    }

} );

