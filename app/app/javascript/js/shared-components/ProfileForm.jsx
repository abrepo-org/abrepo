import React, { useState, useEffect, useCallback } from 'react';
import debounce from "lodash.debounce";
import { ProfileInputTextAutoComplete } from './ProfileInputTextAutoComplete.jsx';
import { Button } from './Button.jsx';
import { updateURL, buildFormQuery } from './Util.js';
import { ProfileTags } from './ProfileTags.jsx';
import { ProfileSearchFilter } from './ProfileSearchFilter.jsx';

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

    const [isInit, setIsInit] = useState(true);
    const [selectedTags, setSelectedTags] = useState( () => {
        return searchParamsQuery
            .split(" ")
            .filter(q => q && q.startsWith("[") && q.endsWith("]"))
            .map(q => q.slice(1, -1));
    });
    const [initTags, setInitTags] = useState( selectedTags );

    const [selectedIndustries, setSelectedIndustries] = useState( () => {
        return searchParamsQuery
            .split(" ")
            .filter(q => q && q.startsWith("{") && q.endsWith("}"))
            .map(q => q.slice(1, -1));
    });
    const [initIndustries, setInitIndustries] = useState( selectedIndustries );

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


    const debouncedFetchAPI = useCallback(
        debounce( (formQuery) => fetchAPI(formQuery), 250),
	[]
    );

    const fetchAPI = (formQuery) => {
        console.log("fetch", formQuery);

        const url = `${props.baseURL}?query=${formQuery}&partial=true`;

        return fetch(url)
            .then(res => res.text())
            .then(res => {

                const $destination = document.querySelector(props.destinationSelector);
                if($destination) {
                    $destination.outerHTML = res;
                }

                updateURL && updateURL(formQuery);
                setInputBusy && setInputBusy(false);
            });
    };

    /*
     * hooks n render
     */

    useEffect( () => {
        console.log("[ProfileForm] init");
        //initial load; decouple values from
        //ProfileInputTextAutoComplete component changes
        setInitTags(selectedTags);
        setInitIndustries(selectedIndustries);
        setIsInit(false);
    }, []);

    useEffect( () => {
        console.log("[ProfileForm] useEffect Tags", selectedTags, selectedIndustries)
        setFormQuery( buildFormQuery(selectedQuery, selectedTags, selectedIndustries) );
    }, [selectedTags, selectedIndustries]);

    useEffect( () => {
        console.log("[ProfileForm] useEffect Fetch", selectedQuery, formQuery)
        const _formQuery = buildFormQuery(selectedQuery,
                                          selectedTags,
                                          selectedIndustries);
        setFormQuery(_formQuery);

        if (!isInit) {
            //avoid ovewriting url params on initial load
            //with "empty" autocomplete query
            debouncedFetchAPI(_formQuery);
        }

    }, [selectedQuery]);


    console.log("[ProfileForm] RENDER", selectedQuery);
    return(
        <div>
            <form id="tag-filter"
                  className="is-flex"
                  action={props.baseURL}
                  acceptCharset="UTF-8"
                  method="get">

                <input autoComplete="off"
                       className="input is-small"
                       type="hidden"
                       name="query"
                       id="formQuery"
                       value={formQuery}
                />

                <ProfileInputTextAutoComplete setInputBusy={setInputBusy}
                                              setSelectedQuery={setSelectedQuery}
                                              selectedQuery={selectedQuery}
                                              selectedTags={selectedTags}
                                              selectedIndustries={selectedIndustries}
                                              { ...props } />


                <Button disabled={inputBusy} />

                <div className="ml-4"></div>

                <ProfileSearchFilter
                    selectedTags={selectedTags}
                    setSelectedTags={setSelectedTags}
                    filterOpenState={filterOpenState}
                    setFilterOpenState={setFilterOpenState}
                    id="1"
                    queryField="query"
                    name="Tags"
                    placeholder="CTA, home page"
                    baseURL="/tags.json" />

                <ProfileSearchFilter
                    selectedTags={selectedIndustries}
                    setSelectedTags={setSelectedIndustries}
                    filterOpenState={filterOpenState}
                    setFilterOpenState={setFilterOpenState}
                    id="2"
                    queryField="query"
                    name="Industries"
                    placeholder='Internet, Media'
                    baseURL="/industries.json" />



            </form>

            <div className="field">

                <ProfileTags
                    baseURL={props.baseURL}
                    buildFormQuery={buildFormQuery}
                    selectedQuery={selectedQuery}
                    selectedTags={initTags}
                    selectedIndustries={initIndustries}
                />

            </div>
        </div>
    );

};

export default { ProfileForm };
