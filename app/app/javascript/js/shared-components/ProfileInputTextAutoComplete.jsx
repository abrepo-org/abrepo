import React, { useState, useEffect, useCallback } from 'react';
import debounce from "lodash.debounce";
import { ProfileTags } from './ProfileTags.jsx';

export const ProfileInputTextAutoComplete = (props) => {

    const baseURL = props.baseURL;
    const destinationSelector = props.destinationSelector;
    const setInputResults = props.setInputResults;
    const placeholder = props.placeholder;
    const updateURL = props.updateURL;

    //value of input text only
    const [query, setQuery] = useState( props.selectedQuery );

    //final "formQuery" for combined search
    ///profiles: query, tags, industries
    const [formQuery, setFormQuery] = useState( props.formQuery );


    const debouncedFetchAPI = useCallback(
        debounce( (query, formQuery) => fetchAPI(query, formQuery), 500),
	[]
    );

    const fetchAPI = (value, formQuery) => {
        //console.log("fetch", formQuery);

        const url = `${baseURL}?query=${formQuery}&partial=true`;

        return fetch(url)
            .then(res => res.text())
            .then(res => {

                /*
                 * pass querySelector if update content is external
                 * of Form / React App
                 * otherwise call setInputResults
                 */

                //update content with available options
                const $destination = document.querySelector(destinationSelector);
                if($destination) {
                    $destination.outerHTML = res;
                }

                //updateValue
                setInputResults && setInputResults(res);

                props.setInputBusy && props.setInputBusy(false);
            });
    };

    const changeHandler = (e) => {
        //console.log("ChangeHandler", e.target.value);
        props.setInputBusy && props.setInputBusy(true);

        setQuery(e.target.value);
        props.setSelectedQuery(e.target.value);
    };


    /*
     * hooks n render
     */

    useEffect( () => {
        debouncedFetchAPI(query, formQuery);
        setFormQuery(props.formQuery);
        updateURL && updateURL(formQuery);
    });


    return(
        <div>
            <div className="field">
                <div id="search-control" className="control has-icons-left">

                     <input onChange={(e) => changeHandler(e) }
                            autoComplete="off"
                            className="input is-small"
                            placeholder={placeholder}
                            type="text"
                            id="query"
                            value={query}
                     />


                     <input autoComplete="off"
                            className="input is-small"
                            type="hidden"
                            name="query"
                            id="formQuery"
                            value={formQuery}
                     />


                     <span className="icon is-small is-left">
                         <i className="fas fa-search"></i>
                     </span>
                </div>
            </div>

            <div className="field">

              <ProfileTags
                    baseURL={baseURL}
                    buildFormQuery={props.buildFormQuery}
                    query={query}
                    selectedTags={props.selectedTags}
                    selectedIndustries={props.selectedIndustries}
                />

            </div>

        </div>
    );

};

export default { ProfileInputTextAutoComplete };
