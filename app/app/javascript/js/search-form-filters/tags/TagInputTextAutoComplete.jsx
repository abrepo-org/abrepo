import React, { useState, useEffect, useCallback } from 'react';
import { updateURL } from '../Util.js';
import debounce from "lodash.debounce";

export const TagInputTextAutoComplete = (props) => {

    const baseURL = props.baseURL;
    const destinationSelector = props.destinationSelector;
    const setInputResults = props.setInputResults;
    const placeholder = props.placeholder;
    const queryField = props.queryField || "query";

    let searchParams = new URLSearchParams(window.location.search);
    const [query, setQuery] = useState( (searchParams && searchParams.get(queryField)) || '' );

    const debouncedFetchAPI = useCallback(
        debounce(value => fetchAPI(value), 500),
	[]
    );

    const fetchAPI = (value) => {

        const url = `${baseURL}?query=${value}&partial=true`;

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

                //updateURL bar w/ change
                updateURL && updateURL(value);

                props.setInputBusy && props.setInputBusy(false);
            });
    };

    const changeHandler = (e) => {

        props.setInputBusy && props.setInputBusy(true);

        setQuery(e.target.value);

        debouncedFetchAPI(e.target.value);
    };


    return(
        <div>
            <div className="field">
                <div id="search-control" className="control has-icons-left">

                     <input onChange={(e) => changeHandler(e) }
                            autoComplete="off"
                            className="input is-small"
                            placeholder={placeholder}
                            type="text"
                            name="query" id="query"
                            value={query}
                     />

                     <span className="icon is-small is-left">
                         <i className="fas fa-search"></i>
                     </span>
                </div>
            </div>
        </div>
    );

};

export default { TagInputTextAutoComplete };
