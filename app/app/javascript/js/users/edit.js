document.addEventListener('DOMContentLoaded', () => {

    const $form = document.querySelector('form#cancel-account');
    if (!$form) return;

    const $input = $form.querySelector('input[data-confirm]');
    if (!$input) return;

    $form.addEventListener('submit', (e) => {

        const confirm_txt = $input.dataset.confirm;
        const confirm  = window.confirm(confirm_txt);

        if (!confirm) {
            e.preventDefault();
            return;
        }
    });

});
