import React, { useState, useEffect } from 'react';
import { ProfileInputTextAutoComplete } from './ProfileInputTextAutoComplete.jsx';
import { Button } from './Button.jsx';
import { updateURL } from './URLUpdater.js';

import { SearchFilter } from './SearchFilter.jsx';

export const ProfileForm = (props) => {

    //form state
    const [formActionURL, setFormActionURL]  = useState(props.baseURL);
    const [inputBusy, setInputBusy] = useState(false);
    const [filterOpenState, setFilterOpenState] = useState({
        '1': false,
        '2': false
    });

    //initial url querystring 'query' param
    const searchParams = new URLSearchParams(window.location.search);
    const searchParamsQuery = searchParams && searchParams.get("query") || '';

    const buildFormQuery = (selectedQuery, selectedTags, selectedIndustries) => {

        return [
            selectedQuery,
            selectedTags.map( tag => `[${tag}]`).join(" "),
            selectedIndustries.map( tag => `{${tag}}`).join(" ")
        ].filter(q => q)
         .join(" ")
         .trim();
    };

    const [selectedTags, setSelectedTags] = useState( () => {
        return searchParamsQuery
            .split(" ")
            .filter(q => q && q.startsWith("[") && q.endsWith("]"))
            .map(q => q.slice(1, -1));
    });

    const [selectedIndustries, setSelectedIndustries] = useState( () => {
        return searchParamsQuery
            .split(" ")
            .filter(q => q && q.startsWith("{") && q.endsWith("}"))
            .map(q => q.slice(1, -1));
    });

    const [selectedQuery, setSelectedQuery] = useState( () => {
        return searchParamsQuery
            .split(" ")
            .filter(q => q && !q.startsWith("{") && !q.endsWith("}"))
            .filter(q => q && !q.startsWith("[") && !q.endsWith("]"));
    });

    //query string for form submission
    const [formQuery, setFormQuery] = useState( () => {
        return buildFormQuery(selectedQuery, selectedTags, selectedIndustries);
    });


    /*
     * hooks n render
     */

    useEffect( () => {
        const _formQuery = buildFormQuery(selectedQuery, selectedTags, selectedIndustries);
        setFormQuery(_formQuery);
    });

    return(
        <form id="tag-filter"
              className="is-flex"
              action={props.baseURL}
              acceptCharset="UTF-8"
              method="get">

            {
                /*
                 * NB: we stick setSelectedQuery to get auto
                 * complete value but build the formQuery here (w/ tags)
                 */
            }

            <ProfileInputTextAutoComplete updateURL={updateURL}
                                          setInputBusy={setInputBusy}
                                          setSelectedQuery={setSelectedQuery}
                                          selectedQuery={selectedQuery}
                                          selectedTags={selectedTags}
                                          selectedIndustries={selectedIndustries}
                                          buildFormQuery={buildFormQuery}
                                          formQuery={formQuery}
                                          { ...props } />

            <Button disabled={inputBusy} />

            <div class="ml-4"></div>

            {props.filters &&
             <>
             <SearchFilter
                 selectedTags={selectedTags}
                 setSelectedTags={setSelectedTags}
                 filterOpenState={filterOpenState}
                 setFilterOpenState={setFilterOpenState}
                 id="1"
                 queryField="query"
                 name="Tags"
                 placeholder="CTA, home page"
                 baseURL="/tags.json" />

             <SearchFilter
                 selectedTags={selectedIndustries}
                 setSelectedTags={setSelectedIndustries}
                 filterOpenState={filterOpenState}
                 setFilterOpenState={setFilterOpenState}
                 id="2"
                 queryField="query"
                 name="Industries"
                 placeholder='Internet, Media'
                 baseURL="/industries.json" />

             </>
            }

        </form>
    );

};

export default { ProfileForm };
