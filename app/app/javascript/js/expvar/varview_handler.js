/*
 * shared/expvar_table handler to toggle classes onClick
 */

function varViewClickHandler($rootDiv, vendor_id) {
    console.log("varViewClickHandler", vendor_id);

    //get all "child" dupe views
    const $variationViews = document
          .querySelectorAll(`[data-vendor="${vendor_id}"]`);

    $rootDiv.querySelectorAll(['i.fa-caret-right', 'i.fa-caret-down'])
        .forEach( $i => $i.classList.toggle('is-hidden'));

    $variationViews.forEach($v => $v.classList.toggle('is-hidden'));
    $rootDiv.querySelectorAll('.see-more')
        .forEach( $div => $div.classList.toggle('is-hidden'));;
};

document.addEventListener('DOMContentLoaded', () => {

    /* attach click handlers to 'root' variation-view */
    const $variationRoots = document
          .querySelectorAll('[data-root-vendor-id]')
          .forEach( $div => {

              const vendor_id = $div.dataset.rootVendorId;

              $div.addEventListener('click', (e) => {

                  //*want* to follow link, and not run js
                  if(e.target.tagName != "A") {
                      varViewClickHandler($div, vendor_id);
                  }
              });
          });

});
