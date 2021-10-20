document.addEventListener('DOMContentLoaded', () => {

    const $modal = document.querySelector('#subscribe-modal');

    if(!$modal) return;

    //close button click
    $modal
        .querySelector('.modal-close')
        .addEventListener('click', (e) => {

            $modal.classList.toggle('is-active');
    });


    //initially open on load (cookie)
    if($modal.classList.contains('is-active')) {

        //add ESC
        const keyPress = (e) => {

            if(e.key === "Escape") {
                $modal.classList.toggle('is-active');
                document.removeEventListener('keydown', keyPress);
            }
        };

        document.addEventListener('keydown', keyPress);
    }

});
