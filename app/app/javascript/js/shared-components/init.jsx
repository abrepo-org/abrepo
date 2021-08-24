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
    const $profileForm = document.querySelector('form#profile-form');

    const $inputTemp = document.createElement('div');

    const render = ($form, props) => {
        ReactDOM.render(
            <FormTag {...props} />,
            $inputTemp
        );

        $form.replaceWith($inputTemp);
    };


    if ($tagForm) {
        const props = {
            baseURL: '/tags',
            destinationSelector: 'ul.tags',
            placeholder: "Filter Tags"
        };
        render($tagForm, props );
    }

    if ($industryForm) {
        const props = {
            baseURL: '/industries',
            destinationSelector: 'ul.tags',
            placeholder: "Filter Industries"
        };
        render($industryForm, props);
    }

    if ($searchForm) {
        const props = {
            baseURL: '/search',
            destinationSelector: 'pre',
            placeholder: "Search"
        };

        ReactDOM.render(
            <SearchForm tags={true}
                        industries={true}
                        {...props} />,
            $inputTemp
        );

        $searchForm.replaceWith($inputTemp);
    }

    if ($profileForm) {
        const props = {
            baseURL: '/profiles',
            destinationSelector: 'pre',
            placeholder: "Search"
        };

        ReactDOM.render(
            <SearchForm industries={true}
                        {...props} />,
            $inputTemp
        );

        $profileForm.replaceWith($inputTemp);
    }
});
