import React, {useState} from 'react';
import ReactDOM from 'react-dom';

const DiffViewMinContainer = (props) => {

    const [active, setActive] = useState(false);

    const icon = active ? "fas fa-caret-down" : "fas fa-caret-right";
    const isVisible = active ? "is-visible" : "is-hidden";

    const headerStyle = {
        cursor: 'pointer'
    };

    return(
        <div>
          <hr />

          <h5 style={headerStyle}
              onClick={(e) => setActive(!active) }>

            <i className={`${icon}`}></i>&nbsp;

            Minor Style Diffs
          </h5>

          <div className={ `${isVisible}` }>
            {/*
            <div className="is-size-7">
              Minor style changes
            </div>
            */}
            { props.children }
          </div>
        </div>
    );
};


export default DiffViewMinContainer;
