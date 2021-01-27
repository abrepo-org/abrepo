import React from 'react';
import ReactDOM from 'react-dom';

export default class RenderableScroll extends React.Component {

    constructor(props) {
        console.log("RenderableScroll");
        super(props);

        this.scrollBlockRef = React.createRef();
    }


    wheelHandler(e) {

        if (this.props.scrollBoxEnabled) {
            e.preventDefault();
            //TODO: add debounce
            console.log(e);

            this.props.scrollListener(e.deltaY);
        }
    }

    componentDidMount() {
        this.scrollBlockRef.current.addEventListener('wheel', this.wheelHandler.bind(this));
    }

    componentWillUnmount() {
        this.scrollBlockRef.current.removeEventListener('wheel', this.wheelHandler.bind(this));
    }

    render() {

        const scrollBlockStyle = {
            position: 'absolute',
            width: '100%',
            height: 'max-content'
        };

        return (
            <div className="scrollBlock is-invisible-touch is-invisible-desktop-only"
                 style={scrollBlockStyle}
                 ref={this.scrollBlockRef}>
                {this.props.children}
            </div>
        );
    }
}
