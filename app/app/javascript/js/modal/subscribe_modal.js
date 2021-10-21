/*
 * Modal listeners to click close and 'ESC' keyPress
 * run once on $modal param
 */

const attach_modal_listeners = ($modal, toggleClass) => {

    //close button click
    //no close button, behavior is not to close
    const $close = $modal.querySelector('.modal-close')
    if (!$close) return;

    $close.addEventListener('click', (e) => {
        $modal.classList.toggle(toggleClass);
    });

    //add ESC handler to close
    const keyPress = (e) => {
        console.log(e.key)
        if(e.key === "Escape" && $modal.classList.contains(toggleClass)) {
            $modal.classList.toggle(toggleClass);
        }
    };

    document.addEventListener('keydown', keyPress);
};



document.addEventListener('DOMContentLoaded', () => {

    const $modal = document.querySelector('#subscribe-modal');
    if (!$modal) return;

    attach_modal_listeners($modal, 'is-active');
});
