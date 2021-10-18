document.addEventListener('DOMContentLoaded', () => {

    const $modal = document.querySelector('#subscribe-modal');

    /*
    const keyPress = (e) => {
        console.log("KP", e);
        if(e.key === "Escape") {
            $modal.classList.toggle('is-active');
            $modal.removeEventListener(keyPress);
        }
    };

    $modal.addEventListener('keypress', keyPress);
    */

    //close button click
    $modal
        .querySelector('.modal-close')
        .addEventListener('click', (e) => {

        $modal.classList.toggle('is-active');
    });

});
