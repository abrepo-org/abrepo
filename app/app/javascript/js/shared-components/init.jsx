import React from 'react';
import ReactDOM from 'react-dom';
import { InputAutoCompleteForm } from './InputAutoCompleteForm.jsx';

/*
 * used for autocomplete and submit on /tags and /industries
 */
document.addEventListener('DOMContentLoaded', () => {

    const $tagForm = document.querySelector('form#tag-filter');
    const $industryForm = document.querySelector('form#industries-filter');

    const $inputTemp = document.createElement('div');

    const render = ($form, props) => {
        ReactDOM.render(
            <InputAutoCompleteForm {...props} />,
            $inputTemp
        );

        $form.replaceWith($inputTemp)
    };

    if ($tagForm) {
        const props = { baseURL: '/tags', destination: 'ul.tags'};
        render($tagForm, props );
    }


    if ($industryForm) {
        const props = { baseURL: '/industries', destination: 'ul.tags'};
        render($industryForm, props);
    }

});
