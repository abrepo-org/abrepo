import React, { useState, useEffect, useCallback } from 'react';
import debounce from "lodash.debounce";

export const SearchInputTextAutoComplete = (props) => {

    const baseURL = props.baseURL;
    const destinationSelector = props.destinationSelector;
    const setAutoCompleteResults = props.setAutoCompleteResults;
    const setAutoCompleteTotals = props.setAutoCompleteTotals;
    const placeholder = props.placeholder;
    const updateURL = props.updateURL;
    const queryField = props.queryField;

    const [query, setQuery] = useState('');

    const debouncedFetchAPI = useCallback(
        debounce(value => fetchAPI(value), 200),
	[props.resetTrigger]
    );

    //NB: these hit the *.json* endpoint
    //so the response does differ from the resource (tags/industries)
    //autocomplete forms which request html

    const fetchAPI = (value) => {

        return fetch(`${baseURL}?query=${value}&partial=true`)
            .then(res => res.json())
            .then(json => {

                //updateValue (setAutoCompleteTags)
                const res = json.results;
                const totalTags = json.total;

                //filter out already selected
                const autocompleteTags = res.map( tag => tag.name)
                                            .filter(name => !props.selectedTags.includes(name));

                setAutoCompleteResults && setAutoCompleteResults(autocompleteTags);
                setAutoCompleteTotals && setAutoCompleteTotals(totalTags);

                //updateURL bar w/ change
                updateURL && updateURL(value);

            });
    };

    const changeHandler = (e) => {

        setQuery(e.target.value);

        debouncedFetchAPI(e.target.value);
    };


    /*
     * NB: useEffect is called on each update
     * an empty array is equivalent to componentDidMount(), called once
     * on initial render.
     * resetTrigger provides change condition to run useEffect;
     */
    useEffect( () => {
        //console.log("[SearchInputTextAutoComplete] useEffect", props.resetTrigger);

        //seems like we don't want to clear the autocomplete query on
        //click
        //setQuery('');

        debouncedFetchAPI(query);

    }, [props.resetTrigger]);

    const controlStyle = {
        width: '20rem',
        overflow: 'auto'
    };

    const inputStyle = {
        border: 'none',
        boxShadow: 'none',
        marginLeft: '-0.5rem'
    };

    const tag_color_class = props.name == "Industries" ?
                            "is-warning" : "is-info";

    //selected autocomplete tags
    return(
        <div className="field">
          <div id="search-control-tag"
               className="control input"
               style={controlStyle}>

              {
                  props.selectedTags.map( tag => {
                      return(
                          <span key={tag}
                                className="tags is-inline-flex is-flex-wrap-nowrap has-addons mb-0 mr-2">
                              <span className={`tag ${tag_color_class} mb-0`}>
                                  {tag}
                              </span>
                              <a className="tag is-delete mb-0"
                                 onClick={() => props.removeTag(tag)}></a>
                          </span>
                      );
                  })
              }

              {/* the input field that sends to auto complete */}
              <input style={inputStyle}
                     onChange={(e) => changeHandler(e) }
                     autoComplete="off"
                     className="input is-small"
                     placeholder={placeholder}
                     type="text"
                     id={`${queryField}-tags`}
                     value={query}
              />


          </div>
        </div>
    );

};

export default { SearchInputTextAutoComplete };
