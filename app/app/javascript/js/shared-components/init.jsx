import React from 'react';
import ReactDOM from 'react-dom';
import { TagForm } from './TagForm.jsx';
import { ProfileForm } from './ProfileForm.jsx';
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
    $inputTemp.style.cssText="margin-bottom:2.25rem;";

    const render = ($form, props) => {
        ReactDOM.render(
            <TagForm {...props} />,
            $inputTemp
        );

        $form.replaceWith($inputTemp);
    };


    if ($tagForm) {
        const props = {
            baseURL: '/tags',
            destinationSelector: '#autocomplete-destination',
            placeholder: "Filter Tags"
        };
        render($tagForm, props );
    }

    if ($industryForm) {
        const props = {
            baseURL: '/industries',
            destinationSelector: '#autocomplete-destination',
            placeholder: "Filter Industries"
        };
        render($industryForm, props);
    }

    if ($profileForm) {

        const params = new URLSearchParams(window.location.search);

        const props = {
            baseURL: '/profiles',
            destinationSelector: '#autocomplete-destination',
            placeholder: "Filter Companies"
        };

        ReactDOM.render(
            <ProfileForm {...props} />,
            $inputTemp
        );

        $profileForm.replaceWith($inputTemp);
    }

    if ($searchForm) {
        const props = {
            baseURL: '/search',
            destinationSelector: 'pre',
            placeholder: "Search Experiments"
        };

        ReactDOM.render(
            <SearchForm tags={true}
                        industries={true}
                        {...props} />,
            $inputTemp
        );

        $searchForm.replaceWith($inputTemp);
    }

});
