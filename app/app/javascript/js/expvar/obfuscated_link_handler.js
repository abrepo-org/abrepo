/*
 * attaches click handlers on obfuscated links to launch modal
 */
function attach_modal_to_obfuscated_links($modal, $links) {

    $links.forEach( $link => {

        $link.addEventListener('click', (e) => {
            e.preventDefault();
            $modal.classList.toggle('is-active');
        });

    });
}



document.addEventListener('DOMContentLoaded', () => {

    const $links = Array.from( document.querySelectorAll('.obfuscated-link') );
    const $modal = document.querySelector('#subscribe-modal');

    if ($links.length && $modal) {
        attach_modal_to_obfuscated_links($links, $modal);
    }

});
