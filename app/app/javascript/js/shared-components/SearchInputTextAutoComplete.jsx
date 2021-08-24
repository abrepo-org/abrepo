import React, { useState, useEffect, useCallback } from 'react';
import debounce from "lodash.debounce";

export const SearchInputTextAutoComplete = (props) => {

    const baseURL = props.baseURL;
    const destinationSelector = props.destinationSelector;
    const setAutoCompleteResults = props.setAutoCompleteResults;
    const placeholder = props.placeholder;
    const updateURL = props.updateURL;
    const queryField = props.queryField;

    let searchParams = new URLSearchParams(window.location.search);
    const [query, setQuery] = useState('');

    const debouncedFetchAPI = useCallback(
        debounce(value => fetchAPI(value), 500),
	[]
    );

    const fetchAPI = (value) => {

        return fetch(`${baseURL}?query=${value}&partial=true`)
            .then(res => res.json())
            .then(res => {

                //updateValue (setAutoCompleteTags)
                const autocompleteTags = res.map( tag => tag.name);
                setAutoCompleteResults && setAutoCompleteResults(autocompleteTags);

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

    //reset trigger
    useEffect( () => {
        console.log("useEffect", props.resetTrigger);
        setQuery("");

    }, [props.resetTrigger]);

    const controlStyle = {
        width: '20rem'
    };

    const inputStyle = {
        border: 'none',
        boxShadow: 'none',
        marginLeft: '-0.5rem'
    };


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
                              <span className="tag is-info mb-0">
                                  {tag}
                              </span>
                              <a className="tag is-delete mb-0"
                                 onClick={() => props.removeTag(tag)}></a>
                          </span>
                      );
                  })
              }

              { /*TODO: refactor to a better place -own .field */
                  props.selectedTags.map( tag => {
                      return(
                          <input key={`input-${tag}`}
                                 type="text"
                                 hidden={true}
                                 name={queryField}
                                 defaultValue={tag} />
                      );
                  })
              }

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
