import React, { useState, useEffect } from 'react';
import { SearchInputTextAutoComplete } from './SearchInputTextAutoComplete.jsx';
import { AutoCompleteTag } from './AutoCompleteTag.jsx';

export const SearchFilter = (props) => {

    const [autocompleteTags, setAutocompleteTags] = useState([]);
    const [autocompleteTotals, setAutocompleteTotals]  = useState(false);
    const [resetTrigger, setResetTrigger] = useState(0);

    const addTag = (tag) => {
        props.setSelectedTags(selectedTags => [...selectedTags, tag])
        setResetTrigger(resetTrigger+1);
    };

    const removeTag = (tag) => {
        props.setSelectedTags(selectedTags => selectedTags.filter(t => t != tag))
        setResetTrigger(resetTrigger+1);
    };

    const clearSelected = () => {
        setAutocompleteTags([])           //clear auto complete list
        setResetTrigger(resetTrigger+1)   //trigger useEffect hook to clear input value
    };

    //open close Tag dropdown
    const openCloseClickHandler = (e) => {
        e.preventDefault();
        const update = {}
        update[props.id] = !props.filterOpenState[props.id]

        //close All
        Object.keys(props.filterOpenState).forEach( key => {
            props.filterOpenState[key] = false;
        });

        //toggle individual (open or close)
        props.setFilterOpenState( {...props.filterOpenState, ...update });
    };

    const cancelStyle = {
        padding: 'calc(0.5em - 2px) 1em calc(0.5em - 1px) 1em',
        display: 'inline-flex'
    }

    return(

        <div className="field mr-2">

            <div className={`dropdown ${props.filterOpenState[props.id] ? 'is-active' : ''}`}>
                <div className="dropdown-trigger">
                    <button className="button is-small"
                            type="button"
                            onClick={(e) => openCloseClickHandler(e)}
                            aria-haspopup="true"
                            aria-controls="dropdown-menu-tag">
                        <span>Filter by {props.name}</span>
                        <span className="icon is-small">
                            <i className="fas fa-angle-down" aria-hidden="true"></i>
                        </span>
                    </button>
                </div>

                <div className="dropdown-menu" id="dropdown-menu-tag" role="menu">
                    <div className="dropdown-content">

                        <div className="dropdown-item">

                            <p className="is-flex is-justify-content-space-between">
                                <span>
                                    <strong>Filter by {props.name}</strong>
                                </span>
                            </p>

                            <SearchInputTextAutoComplete
                                baseURL={props.baseURL}
                                queryField={props.queryField}
                                resetTrigger={resetTrigger}
                                setAutoCompleteResults={setAutocompleteTags}
                                setAutoCompleteTotals={setAutocompleteTotals}
                                selectedTags={props.selectedTags}
                                removeTag={removeTag}
                                placeholder={props.placeholder}
                            />

                            <div id="tag-destination">

                                <ul className="tags ml-0 is-inline">

                                    {
                                        autocompleteTags.map( (tag, i) => {
                                            return (<AutoCompleteTag key={tag}
                                                                     tag={tag}
                                                                     i={i}
                                                                     clearSelected={clearSelected}
                                                                     addTag={addTag} />);
                                        })
                                    }

                                </ul>


                                {!!autocompleteTotals &&
                                 <div className="ml-1 mt-2">
                                     <a href={`/${props.name.toLowerCase()}/`}>
                                         {`See All ${props.name}`}
                                         {autocompleteTotals ? ` (${autocompleteTotals})` : '' }
                                     </a>
                                 </div>
                                }

                            </div>
                        </div>

                        <hr className="dropdown-divider" />
                        <div className="dropdown-item">
                            <button className="button is-small">
                                Apply Filters
                            </button>
                            <a href="#" style={cancelStyle}
                               onClick={(e) => openCloseClickHandler(e)}>
                                Cancel
                            </a>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    );

};
