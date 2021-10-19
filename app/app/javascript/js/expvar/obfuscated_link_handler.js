function obfuscated_click_handler($links) {

    $links.forEach( $link => {

        $link.addEventListener('click', (e) => {
            e.preventDefault();

            const $modal = document
                  .querySelector('#subscribe-modal');

            $modal.classList
                .toggle('is-active');


            //add ESC
            const keyPress = (e) => {

                if(e.key === "Escape") {
                    $modal.classList.toggle('is-active');
                    document.removeEventListener('keydown', keyPress);
                }
            };

            document.addEventListener('keydown', keyPress);
        });

    });

}

document.addEventListener('DOMContentLoaded', () => {

    const $links = Array.from( document.querySelectorAll('.obfuscated-link') );

    obfuscated_click_handler($links);

});
