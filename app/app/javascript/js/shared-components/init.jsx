import React from 'react';
import ReactDOM from 'react-dom';
import { FormTag } from './FormTag.jsx';
import { SearchForm } from './SearchForm.jsx';

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
            <FormTag {...props} />,
            $inputTemp
        );

        $form.replaceWith($inputTemp);
    };


    if ($tagForm) {
        const props = { baseURL: '/tags', destination: 'ul.tags'};
        render($tagForm, props );
    }

    if ($industryForm) {
        const props = { baseURL: '/industries', destination: 'ul.tags'};
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
