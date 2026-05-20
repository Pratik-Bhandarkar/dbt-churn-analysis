{% macro classify_engagement(event_count) %}
    case
        when {{ event_count }} >= 10 then 'high'
        when {{ event_count }} >= 3  then 'medium'
        else                              'low'
    end
{% endmacro %}