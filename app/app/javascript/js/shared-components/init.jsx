import React from 'react';
import ReactDOM from 'react-dom';
import { InputAutoCompleteForm } from './InputAutoCompleteForm.jsx';
import { SearchForm } from './SearchForm.jsx';
import { updateURL } from './URLUpdater.js';
/*
 * used for autocomplete and submit on /tags and /industries
 */
document.addEventListener('DOMContentLoaded', () => {

    const $tagForm = document.querySelector('form#tag-filter');
    const $industryForm = document.querySelector('form#industries-filter');
    const $searchForm = document.querySelector('form#search-form');

    const $inputTemp = document.createElement('div');

    const render = ($form, props) => {
        ReactDOM.render(
            <InputAutoCompleteForm {...props} />,
            $inputTemp
        );

        $form.replaceWith($inputTemp);
    };


    if ($tagForm) {
        const props = { baseURL: '/tags', destination: 'ul.tags', updateURL};
        render($tagForm, props );
    }

    if ($industryForm) {
        const props = { baseURL: '/industries', destination: 'ul.tags', updateURL};
        render($industryForm, props);
    }

    if ($searchForm) {
        const props = {}
        ReactDOM.render(
            <SearchForm {...props} />,
            $inputTemp
        );

        $searchForm.replaceWith($inputTemp)
    }
});
