import React from 'react';
import ReactDOM from 'react-dom';
import SelectDropDown from './SelectDropDown.jsx';

export default class ControlsContainer extends React.Component {

    constructor(props) {
        super(props);
        console.log('controlsContainer');
    }

    render() {
        return(
            <div className="controls">
                <div className="columns">
                    <div className="column is-3 is-hidden-touch">

                        <div className="columns">
                            <div className="column is-full">
                                {/* not sure controls should be sticky */}
                                {/* diff control placeholders */}

                                {this.props.diffVisible &&
                                <>
                                <button>
                                    <span className="icon is-small">
                                        <i className="fas fa-font"></i>
                                    </span>
                                </button>
                                <button>
                                    <span className="icon is-small">
                                        <i className="fab fa-css3"></i>
                                    </span>
                                </button>
                                </>
                                }
                                <button onClick={() => this.props.toggleDiffVisibleHandler()}>

                                    <span className="icon-text">
                                        <span className="icon is-small">
                                        {this.props.diffVisible ?
                                         <i className="far fa-eye-slash"></i> :
                                         <i className="far fa-eye"></i>
                                        }
                                        </span>
                                        {/* <span className="text">Hide</span> */}
                                    </span>
                                </button>

                            </div>
                        </div>

                    </div>

                    <div className="column is-full renderableControls">

                        {/* renderable control placeholders */}

                        <SelectDropDown {...this.props} />

                        <button onClick={() => this.props.togglebboxClickHandler()}>
                            <span className="icon is-small" title="toggle bounding boxes">
                                {this.props.bboxVisible ?
                                 <i className="fas fa-toggle-on"></i> :
                                 <i className="fas fa-toggle-off"></i>
                                }

                            </span>
                        </button>
                        <button className="is-hidden-touch"
                                onClick={() => this.props.toggleScrollBoxHandler()}>
                            <span className="icon is-small" title="toggle scroll adjust">
                                {this.props.scrollBoxEnabled ?
                                 <i className="fas fa-lock-open"></i> :
                                 <i className="fas fa-lock"></i>
                                }
                            </span>
                        </button>

                        {/* reset */}
                        {this.props.scrollBoxEnabled &&
                        <button className="is-hidden-touch"
                                onClick={() => this.props.resetScrollBoxHandler()}>
                            <span className="icon is-small" title="toggle scroll adjust">
                                <i class="fas fa-level-up-alt"></i>
                            </span>
                        </button>
                        }

                    </div>
                </div>
            </div>
        );
    }

}
