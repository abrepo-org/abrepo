function obfuscated_click_handler($links) {

    $links.forEach( $link => {

        $link.addEventListener('click', (e) => {
            e.preventDefault();

            document
                .querySelector('#subscribe-modal')
                .classList
                .toggle('is-active');
        });

    });

}

document.addEventListener('DOMContentLoaded', () => {

    const $links = Array.from( document.querySelectorAll('.obfuscated-link') );

    obfuscated_click_handler($links);

});
