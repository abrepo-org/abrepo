/* animation listener
 * events of interest: { 'animationiteration', 'animationstart' }
 * if there is an animation-delay, will need to listen for the
 * animation-start event. Typically subsequent divs are initially invisible
 * then this listener triggers their visiblility.
 *
 * In cases where there is no delay, don't need to trigger show/hide
 * but rely on animation fade.
 */

document.addEventListener('DOMContentLoaded', () => {

    const $role1a = document.querySelectorAll('.role-1-a');
    const $role1b = document.querySelectorAll('.role-1-b');

    $role1b.forEach($role => {
        $role.addEventListener('animationstart', () => {
            //$role.classList.toggle('is-invisible');
        }, {once:true});
    });
});
